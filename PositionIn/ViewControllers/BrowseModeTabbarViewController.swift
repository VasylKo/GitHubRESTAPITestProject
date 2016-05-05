//
//  BrowseModeTabbarViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

import CleanroomLogger

protocol BrowseModeDisplay {
    var browseMode: BrowseModeTabbarViewController.BrowseMode { get set }
}

@objc class BrowseModeTabbarViewController: DisplayModeViewController, AddMenuViewDelegate, BrowseTabbarDelegate, BrowseGridViewControllerDelegate {
    
    var addMenuItems: [AddMenuView.MenuItem] {
        let pushAndSubscribe: (UIViewController) -> () = { [weak self] controller in
            self?.navigationController?.pushViewController(controller, animated: true)
            self?.subscribeForContentUpdates(controller)
        }
        return [
            AddMenuView.MenuItem.promotionItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    trackEventToAnalytics(AnalyticCategories.ambulance, action: AnalyticActios.actionOpenAmbulance)
                    pushAndSubscribe(Storyboards.Onboarding.instantiateCallAmbulanceViewController())
                }},
            AddMenuView.MenuItem.inviteItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    trackEventToAnalytics(AnalyticCategories.donate, action: AnalyticActios.actionOpenDonate)
                    pushAndSubscribe(Storyboards.Onboarding.instantiateDonateViewController())
                }},
            AddMenuView.MenuItem.postItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    trackEventToAnalytics(AnalyticCategories.post, action: AnalyticActios.actionOpenPost)
                    pushAndSubscribe(Storyboards.NewItems.instantiateAddPostViewController())
                }}
        ]
    }
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.browseMode {
        case .ForYou:
            self.navigationItem.rightBarButtonItems = nil
            let browseGridController = Storyboards.Main.instantiateBrowseGridViewController()
            browseGridController.browseGridDelegate = self
            self.searchbar.attributedText = nil
            self.navigationController?.navigationBar.barTintColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46)
            return browseGridController
        case .New:
            let listController = FeedListViewController(nibName: "FeedListViewController", bundle: nil)
            self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
            self.navigationItem.rightBarButtonItems = nil
            return listController
        }
    }
    
    //MARK: Browse mode
    
    enum BrowseMode: Int, CustomStringConvertible {
        case ForYou
        case New
        
        var description: String {
            switch self {
            case .ForYou:
                return "For you"
            case .New:
                return "New"
            }
        }
    }
    
    var browseMode: BrowseMode = .ForYou {
        didSet {
            if isViewLoaded() {
                applyBrowseMode(browseMode)
                applyDisplayMode(displayMode)
            }
        }
    }
    
    private func applyBrowseMode(mode: BrowseMode) {
        Log.verbose?.message("Apply browse mode: \(mode)")
        tabbar.selectedMode = mode
        NSNotificationCenter.defaultCenter().postNotificationName(
            BrowseModeTabbarViewController.BrowseModeDidchangeNotification,
            object: self,
            userInfo: nil
        )
    }
    
    override func prepareDisplayController(controller: UIViewController) {
        if var display = controller as? BrowseModeDisplay {
            display.browseMode = browseMode
        }
    }

    
    static let BrowseModeDidchangeNotification = "BrowseModeDidchangeNotification"
    
    //MARK: - Views -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar.browseDelegate = self
        addMenu.setItems(addMenuItems)
        addMenu.delegate = self
        
        applyBrowseMode(browseMode)
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: addMenu, action: "toogleMenuTapped:"))
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in
            self.addMenu.update(context)
            }, completion: { context in
                
        })
    }
    
    override func loadView() {
        super.loadView()

        let tabbar = BrowseTabbar()
        self.tabbar = tabbar
        view.addSubview(tabbar)
        
        let addMenu = AddMenuView()
        self.addMenu = addMenu
        view.addSubview(addMenu)
        
        view.removeConstraints(view.constraints)
        tabbar.translatesAutoresizingMaskIntoConstraints = false
        addMenu.translatesAutoresizingMaskIntoConstraints = false
        
        let addMenuSize: CGFloat = 50
        
        let views = [ "tabbar": tabbar, "contentView" : contentView ]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tabbar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView][tabbar(50)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .CenterX, relatedBy: .Equal,
            toItem: addMenu, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .Bottom, relatedBy: .Equal,
            toItem: addMenu, attribute: .Bottom, multiplier: 1.0, constant: 10))
        addMenu.addConstraint(NSLayoutConstraint(
            item: addMenu, attribute: .Width, relatedBy: .Equal,
            toItem: addMenu, attribute: .Height, multiplier: 1.0, constant: 0))
        addMenu.addConstraint(NSLayoutConstraint(
            item: addMenu, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: addMenuSize))
    }

    
    override func applyDisplayMode(mode: DisplayModeViewController.DisplayMode) {
        super.applyDisplayMode(mode)
        addMenu.setExpanded(false, animated: false)
    }

    private(set) internal weak var addMenu: AddMenuView!
    private(set) internal weak var tabbar: BrowseTabbar!

    
    //MARK: - Blur -
    
    var blurDisplayed: Bool = false {
        didSet {
            blurView.hidden = !blurDisplayed
            if blurDisplayed {
                contentView.bringSubviewToFront(blurView)
            }
        }
    }
    
    private lazy var blurView: UIView = { [unowned self] in
        let blur = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blur)
        self.contentView.addSubViewOnEntireSize(blurView)
        blurView.hidden = true
        return blurView
        }()
    
 //MARK: - AddMenuViewDelegate -
    
    func addMenuView(addMenuView: AddMenuView, willExpand expanded:Bool) {
        if expanded {
            blurDisplayed = expanded
        }
    }
    
    func addMenuView(addMenuView: AddMenuView, didExpand expanded: Bool) {
        if !expanded {
            blurDisplayed = expanded
        }
    }
 
//MARK: - BrowseGridViewControllerDelegate
    func browseGridViewControllerSelectItem(homeItem: HomeItem) {
        switch homeItem {
        case .Membership:
            MembershipRouterImplementation().showInitialViewController(from: self)
        case .Volunteer:
            self.navigationController?.pushViewController(Storyboards.Main.instantiateBrowseVolunteerViewController(), animated: true)
        case .News:
            self.navigationController?.pushViewController(NewsContainerViewController(), animated: true)
        case .GiveBlood:
            GiveBloodRouterImplementation().showInitialViewController(from: self)
        case .Market:
            fallthrough
        case .BomaHotels:
            fallthrough
        case .Events:
            fallthrough
        case .Emergency:
            fallthrough
        case .Training:
            fallthrough
        case .Projects:
            // Check NSUserDefaults to show project intro page
            let defaults = NSUserDefaults.standardUserDefaults()
            let isProjectInroShowed = defaults.boolForKey(projectsIntroShowedKey)
            if  !isProjectInroShowed && homeItem == .Projects {
                let projectsIntroController = ProjectsIntroViewController()
                projectsIntroController.browseGridDelegate = self
                self.navigationController?.pushViewController(projectsIntroController, animated: true)
            } else {
                let controller = Storyboards.Main.instantiateExploreViewControllerId()
                controller.homeItem = homeItem
                let filterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    let feedItemType = FeedItem.ItemType(rawValue: homeItem.rawValue)
                    if let feedItemType = feedItemType {
                        f.itemTypes = [feedItemType]
                    }
                    return f
                }
                controller.childFilterUpdate = filterUpdate
                controller.title = homeItem.displayString()
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case .Donate:
            self.navigationController?.pushViewController(Storyboards.Onboarding.instantiateDonateViewController(), animated: true)
        case .Ambulance:
            EPlusMembershipRouterImplementation().showInitialViewController(from: self)
        default:
            break
        }
    }
    
//MARK: - BrowseTabbarDelegate -
    
    @objc func tabbarDidChangeMode(tabbar: BrowseTabbar) {
        if (browseMode != tabbar.selectedMode) {
            browseMode = tabbar.selectedMode
        }
    }
}
