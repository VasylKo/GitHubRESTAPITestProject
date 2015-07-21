//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BrowseViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDisplayMode(mode)
        self.navigationItem.titleView = searchbar


        addMenu.setItems([
            AddMenuView.MenuItem(title: NSLocalizedString("INVITE",comment: "Add menu: INVITE"), icon: UIImage(named: "AddFriend")!, color: UIColor.redColor()),
            AddMenuView.MenuItem(title: NSLocalizedString("PROMOTION",comment: "Add menu: PROMOTION"), icon: UIImage(named: "AddPromotion")!, color: UIColor.greenColor()),
            AddMenuView.MenuItem(title: NSLocalizedString("EVENT",comment: "Add menu: EVENT"), icon: UIImage(named: "AddEvent")!, color: UIColor.blueColor()),
            AddMenuView.MenuItem(title: NSLocalizedString("PRODUCT",comment: "Add menu: PRODUCT"), icon: UIImage(named: "AddProduct")!, color: UIColor.yellowColor()),
            ])
    }

    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var addMenu: AddMenuView!


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
        let blur = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blur)
        self.contentView.addSubViewOnEntireSize(blurView)
        blurView.hidden = true
        return blurView
    }()
    
//MARK: Display mode
    
    var mode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyDisplayMode(mode)
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
            mode = displayMode
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
            switch self.mode {
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
        blurDisplayed = false
    }


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
