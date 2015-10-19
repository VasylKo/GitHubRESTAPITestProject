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

@objc class DisplayModeViewController: BesideMenuViewController, BrowseActionConsumer, SearchViewControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Updates -
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        super.contentDidChange(sender, info: info)
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
        childController.willMoveToParentViewController(self)
        prepareDisplayController(childController)
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
    
    weak var currentModeViewController: UIViewController?
    
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
    
    private lazy var searchbar: UITextField = { [unowned self] in
        let searchBar = UITextField(frame: CGRectMake(0, 0, UIScreen.mainScreen().applicationFrame.size.width * 0.7, 25))
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.borderStyle = UITextBorderStyle.RoundedRect
        let leftView: UIImageView = UIImageView(image: UIImage(named: "search_icon"))
        leftView.frame = CGRectMake(0.0, 0.0, leftView.frame.size.width + 10.0, leftView.frame.size.height);
        leftView.contentMode = .Center
        searchBar.leftView = leftView
        searchBar.leftViewMode = .Always
        searchBar.delegate = self
        return searchBar
        }()
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.presentSearchViewController()
        return false
    }
    
    func presentSearchViewController() {
        SearchViewController.present(searchbar, presenter: self)
    }
    
    func searchViewControllerItemSelected(model: SearchItemCellModel?) {
        
    }
    
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?) {
        
    }
}