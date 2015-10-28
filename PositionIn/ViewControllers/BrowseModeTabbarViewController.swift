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

@objc class BrowseModeTabbarViewController: DisplayModeViewController, AddMenuViewDelegate, BrowseTabbarDelegate {
    
    var addMenuItems: [AddMenuView.MenuItem] {
        return []
    }
    
    //MARK: Browse mode
    
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
        
        view.removeConstraints(view.constraints())
        tabbar.setTranslatesAutoresizingMaskIntoConstraints(false)
        addMenu.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let addMenuSize: CGFloat = 50
        
        let views: [NSObject : AnyObject] = [ "tabbar": tabbar, "contentView" : contentView ]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tabbar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView][tabbar(50)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
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
    
//MARK: - BrowseTabbarDelegate -
    
    @objc func tabbarDidChangeMode(tabbar: BrowseTabbar) {
        browseMode = tabbar.selectedMode
    }
}
