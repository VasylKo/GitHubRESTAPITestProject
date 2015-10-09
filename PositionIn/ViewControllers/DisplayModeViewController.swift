//
//  DisplayModeController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import HMSegmentedControl

protocol BrowseActionProducer {
    var actionConsumer: BrowseActionConsumer? { get set }
}

protocol BrowseActionConsumer: class {
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType, data: Any?)
    func browseControllerDidChangeContent(controller: BrowseActionProducer)
}

@objc class DisplayModeViewController: BesideMenuViewController, BrowseActionConsumer, SearchViewControllerDelegate, UISearchBarDelegate {
    
    //MARK: - Updates -
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        if isViewLoaded() {
            applyDisplayMode(displayMode)
        }
    }
    
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
        prepareDisplayController(childController)
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
    
    func prepareDisplayController(controller: UIViewController) {
        Log.verbose?.message("Preparing display controller: \(controller)")
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
    
    private(set) internal lazy var displayModeSegmentedControl: DisplayModeSegmentedControl = { [unowned self] in
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
    
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType, data: Any?) {
        switch itemType {
        case .Item:
            let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
            controller.objectId = objectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Event:
            let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .Promotion:
            let controller =  Storyboards.Main.instantiatePromotionDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .Post:
            let controller = Storyboards.Main.instantiatePostViewController()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)            
        default:
            Log.debug?.message("Did select \(itemType)<\(objectId)>")
        }
    }
    
    func browseControllerDidChangeContent(controller: BrowseActionProducer) {
        Log.verbose?.message("\(controller) did change content")
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
    
    func searchViewControllerItemSelected(model: SearchItemCellModel?) {
        if let model = model {
            switch model.itemType {
            case .Unknown:
                break
            case .Category:
                break
            case .Product:
                let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Event:
                let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Promotion:
                let controller =  Storyboards.Main.instantiatePromotionDetailsViewControllerId()
                controller.objectId =  model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Community:
                SearchFilter.currentFilter.communities = [model.objectID]
            case .People:
                SearchFilter.currentFilter.users = [model.objectID]
            default:
                break
            }
        }
    }
    
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?) {
        
    }
}