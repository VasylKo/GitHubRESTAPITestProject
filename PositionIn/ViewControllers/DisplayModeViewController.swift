//
//  DisplayModeController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger
import HMSegmentedControl

protocol BrowseActionProducer {
    var actionConsumer: BrowseActionConsumer? { get set }
}

protocol BrowseActionConsumer: class {
    func browseController(controller: BrowseActionProducer, didSelectPost post: Post)
}


@objc class DisplayModeViewController: BesideMenuViewController, BrowseActionConsumer, UISearchBarDelegate {
    
    //MARK: - Display mode -
    
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
    
    var displayMode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyDisplayMode(displayMode)
            }
        }
    }
    
    func viewControllerForMode(mode: DisplayMode) -> UIViewController {
        fatalError("Abstract method call")
    }
    
    func applyDisplayMode(mode: DisplayMode) {
        Log.verbose?.message("Apply display mode: \(mode)")
        parentViewController?.view.endEditing(true)
        if let currentController = currentModeViewController {
            currentController.willMoveToParentViewController(nil)
            currentController.view.removeFromSuperview()
            currentController.removeFromParentViewController()
        }
        
        let childController = viewControllerForMode(self.displayMode)
        childController.willMoveToParentViewController(self)
        self.addChildViewController(childController)
        self.contentView.addSubViewOnEntireSize(childController.view)
        childController.didMoveToParentViewController(self)
        currentModeViewController = childController
        
        //workaround compiler: var because BrowseActionProducer could be a struct
        if var actionProducer = childController as? BrowseActionProducer {
            actionProducer.actionConsumer = self
        }
        
        displayModeSegmentedControl.selectedSegmentIndex = mode.rawValue
    }
    

    //MARK: - UI -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchbar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: displayModeSegmentedControl)
        applyDisplayMode(displayMode)
    }
    
    private(set) internal weak var contentView: UIView!
    
    //MARK: - Display segment -
    
    typealias DisplayModeSegmentedControl = HMSegmentedControl
    
    private(set) internal lazy var displayModeSegmentedControl: DisplayModeSegmentedControl = {
        let items = [
            UIImage(named: "BrowseModeMap")!,
            UIImage(named: "BrowseModeList")!,
        ]
        let selectedItems = [
            UIImage(named: "BrowseModeMapSelected")!,
            UIImage(named: "BrowseModeListSelected")!,
        ]
        
        let segmentControl = DisplayModeSegmentedControl(sectionImages: items, sectionSelectedImages: selectedItems)
        segmentControl.frame = CGRect(origin: CGPointZero, size: CGSize(width: 60, height: 44))
        segmentControl.selectionIndicatorColor = UIColor.whiteColor()
        segmentControl.backgroundColor = UIColor.clearColor()
        segmentControl.segmentEdgeInset = UIEdgeInsetsZero
        segmentControl.selectionIndicatorHeight = 2.0
        segmentControl.borderWidth = 0.0
        segmentControl.userDraggable = false
        segmentControl.verticalDividerEnabled = false
        segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segmentControl.addTarget(self, action: "displayModeSegmentChanged:", forControlEvents: UIControlEvents.ValueChanged)
        return segmentControl
    }()
    
    
    @IBAction private func displayModeSegmentChanged(sender: HMSegmentedControl) {
        if let displayMode = DisplayMode(rawValue: sender.selectedSegmentIndex) {
            self.displayMode = displayMode
        } else {
            fatalError("Unknown display mode in segment control")
        }
    }
    

    //MARK: - Private -
    
    private weak var currentModeViewController: UIViewController?
    
    override func loadView() {
        let view = UIView()
        self.view = view
        let contentView = UIView()
        view.addSubViewOnEntireSize(contentView)
        self.contentView = contentView
    }
    
    //MARK: - BrowseActionConsumer: Browse actions -
    
    func browseController(controller: BrowseActionProducer, didSelectPost post: Post) {
    }

    //MARK: - Search -
    
    private lazy var searchbar: SearchBar = { [unowned self] in
        let searchBar = SearchBar()
        searchBar.delegate = self
        return searchBar
        }()

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        SearchViewController.present(searchbar, presenter: self)
        return false
    }


}