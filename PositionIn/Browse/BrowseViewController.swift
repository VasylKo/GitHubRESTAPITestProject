//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class BrowseViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchbar
        tabbar.browseDelegate = self
        setupAddMenu()
        applyDisplayMode(displayMode)
        applyBrowseMode(browseMode)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in
            self.addMenu.update(context)
        }, completion: { context in
                
        })
    }
    
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var addMenu: AddMenuView!
    @IBOutlet weak var tabbar: BrowseTabbar!
    
//MARK: Blur
    
    var blurDisplayed: Bool = false {
        didSet {
            blurView.hidden = !blurDisplayed
            if blurDisplayed {
                contentView.bringSubviewToFront(blurView)
            }
        }
    }
    
    private lazy var blurView: UIView = {
        let blur = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blur)
        self.contentView.addSubViewOnEntireSize(blurView)
        blurView.hidden = true
        return blurView
    }()
    
//MARK: Display mode
    
    var displayMode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyDisplayMode(displayMode)
            }
        }
    }
    
    enum DisplayMode: Int, Printable {
        case Map = 0
        case List = 1
        
        var description: String {
            switch self {
            case .Map:
                return "Map browse mode"
            case .List:
                return "List browse mode"
            }
        }
    }
    
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!
    
    @IBAction private func displayModeSegmentChanged(sender: UISegmentedControl) {
        if let displayMode = DisplayMode(rawValue: sender.selectedSegmentIndex) {
            self.displayMode = displayMode
        } else {
            fatalError("Unknown display mode in segment control")
        }
    }

    private weak var currentModeViewController: UIViewController?
    
    private func applyDisplayMode(mode: DisplayMode) {
        println("\(self.dynamicType) Apply display mode: \(mode)")
        parentViewController?.view.endEditing(true)
        if let currentController = currentModeViewController {
            currentController.willMoveToParentViewController(nil)
            currentController.view.removeFromSuperview()
            currentController.removeFromParentViewController()
        }
        
        let childController: UIViewController = {
            switch self.displayMode {
            case .Map:
                return Storyboards.Main.instantiateBrowseMapViewController()
            case .List:
                return Storyboards.Main.instantiateBrowseListViewController()
            }
            }()
        childController.willMoveToParentViewController(self)
        self.addChildViewController(childController)
        self.contentView.addSubViewOnEntireSize(childController.view)
        childController.didMoveToParentViewController(self)
        currentModeViewController = childController
        displayModeSegmentedControl.selectedSegmentIndex = mode.rawValue
        addMenu.setExpanded(false, animated: false)
    }

//MARK: Browse mode
    
    var browseMode: BrowseMode = .ForYou {
        didSet {
            if isViewLoaded() {
                applyBrowseMode(browseMode)
            }
        }
    }
    
    static let BrowseModeDidchangeNotification = "BrowseModeDidchangeNotification"
    
    private func applyBrowseMode(mode: BrowseMode) {
        println("\(self.dynamicType) Apply browse mode: \(mode)")
        tabbar.selectedMode = mode
        NSNotificationCenter.defaultCenter().postNotificationName(
            BrowseViewController.BrowseModeDidchangeNotification,
            object: self,
            userInfo: nil
        )
    }
    
    
    enum BrowseMode: Int, Printable {
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
    
//MARK: Search

    private lazy var searchbar: SearchBar = {
        let vPadding: CGFloat = 5
        let frame = CGRect(
            x: 0,
            y: vPadding,
            width: self.view.bounds.width,
            height: self.navigationController!.navigationBar.bounds.height - 2 * vPadding
        )
        let searchBar = SearchBar(frame: frame)
        return searchBar
        }()

}

//MARK: configuration
extension BrowseViewController {
    private func setupAddMenu() {
        addMenu.setItems([
            AddMenuView.MenuItem(
                title: NSLocalizedString("PRODUCT",comment: "Add menu: PRODUCT"),
                icon: UIImage(named: "AddProduct")!,
                color: UIScheme.productAddMenuColor,
                action: {println("Product")}
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("EVENT",comment: "Add menu: EVENT"),
                icon: UIImage(named: "AddEvent")!,
                color: UIScheme.eventAddMenuColor,
                action: {println("Event")}
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("PROMOTION",comment: "Add menu: PROMOTION"),
                icon: UIImage(named: "AddPromotion")!,
                color: UIScheme.promotionAddMenuColor,
                action: {println("Promotion")}
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("INVITE",comment: "Add menu: INVITE"),
                icon: UIImage(named: "AddFriend")!,
                color: UIScheme.inviteAddMenuColor,
                action: {println("invite")}
            ),
        ])
        addMenu.delegate = self
    }
}

//MARK: AddMenuViewDelegate
extension BrowseViewController: AddMenuViewDelegate {
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
}

//MARK:
extension BrowseViewController: BrowseTabbarDelegate {
    func tabbarDidChangeMode(tabbar: BrowseTabbar) {
        browseMode = tabbar.selectedMode
    }
}
