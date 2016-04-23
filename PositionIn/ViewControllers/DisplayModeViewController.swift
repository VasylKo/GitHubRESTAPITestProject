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
    func browseController(controller: BrowseActionProducer, didSelectItem object: Any, type itemType: FeedItem.ItemType, data: Any?)
    func browseControllerDidChangeContent(controller: BrowseActionProducer)
}

@objc class DisplayModeViewController: BesideMenuViewController, BrowseActionConsumer, SearchViewControllerDelegate, BrowseMapViewControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Updates -
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        super.contentDidChange(sender, info: info)
        if isViewLoaded() {
            applyDisplayMode(displayMode)
        }
    }
    
    //MARK: - Display mode -
    
    enum DisplayMode: Int, CustomStringConvertible {
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
    
    var displayMode: DisplayMode = .List {
        didSet {
            if isViewLoaded() {
                applyDisplayMode(displayMode)
                switch displayMode {
                case .Map:
                    trackEventToAnalytics("Main", action: "Click", label: "Map")
                case .List:
                    trackEventToAnalytics("Main", action: "Click", label: "List")                    
                }
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
        
        //Set right bar button item
        //TODO: refactore this
        switch self.childViewControllers.first {
        case is FeedListViewController:
            //right bar button item is set in FeedListViewController (reg line image button)
            break
        case is BrowseGridViewController:
            //right bar button item is set in BrowseGridViewController (notification button)
            break
        default:
            self.navigationItem.rightBarButtonItem = self.barButtonItems[mode.rawValue]
        }
    }
    
    func prepareDisplayController(controller: UIViewController) {
        Log.verbose?.message("Preparing display controller: \(controller)")
    }
    
    //MARK: - UI -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide search functionality
        //self.navigationItem.titleView = searchbar

        self.setRightBarItems()
        
        applyDisplayMode(displayMode)
    }
    
    func setRightBarItems() {
        for imageName in ["list_view_icon", "map_view_icon"] {
            let barButtonItem : UIBarButtonItem  = UIBarButtonItem(image: UIImage(named: imageName),
                                                                   style: .Plain,
                                                                  target: self,
                                                                  action: Selector("barButtonPressed:"))
            self.barButtonItems.append(barButtonItem)
        }

        self.navigationItem.rightBarButtonItem = self.barButtonItems[0]
    }
    
    private(set) internal weak var contentView: UIView!
    
    //MARK: - Display segment -
    
    private var barButtonItems : [UIBarButtonItem] = []

    @IBAction private func barButtonPressed(barButtonItem : UIBarButtonItem) {
        let index = self.barButtonItems.indexOf(barButtonItem)!
        let next = (index == 0) ? 1 : 0
        
        self.navigationItem.setRightBarButtonItem(self.barButtonItems[next], animated: true)
        
        if let displayMode = DisplayMode(rawValue: next) {
            self.displayMode = displayMode
        } else {
            fatalError("Unknown display mode in segment control")
        }
    }
    
    
    //MARK: - Private -
    
    var childFilterUpdate: SearchFilterUpdate?
    var searchString: String?
    
    weak var currentModeViewController: UIViewController?
    
    override func loadView() {
        let view = UIView()
        self.view = view
        let contentView = UIView()
        view.addSubViewOnEntireSize(contentView)
        self.contentView = contentView
    }
    
    //MARK: - BrowseActionConsumer: Browse actions -
    
    func browseController(controller: BrowseActionProducer, didSelectItem object: Any, type itemType: FeedItem.ItemType, data: Any?) {
        switch itemType {
        case .Project:
            trackEventToAnalytics("Main", action: "Click", label: "Product")
            let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Training:
            trackEventToAnalytics("Main", action: "Click", label: "Training")
            let controller =  Storyboards.Main.instantiateTrainingDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Emergency:
            trackEventToAnalytics("Main", action: "Click", label: "Emergency")
            let controller =  Storyboards.Main.instantiateEmergencyDetailsControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .BomaHotels:
            trackEventToAnalytics("Main", action: "Click", label: "BomaHotels")
            let controller =  Storyboards.Main.instantiateBomaHotelsDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .GiveBlood:
            trackEventToAnalytics("Main", action: "Click", label: "GiveBlood")
            let controller =  Storyboards.Main.instantiateGiveBloodDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Market:
            trackEventToAnalytics("Main", action: "Click", label: "Post")
            let controller = Storyboards.Main.instantiateMarketDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Volunteer:
            trackEventToAnalytics("Main", action: "Click", label: "Post")
            let controller = Storyboards.Main.instantiateVolunteerDetailsViewControllerId()
            controller.volunteer = object as? Community
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Post:
            trackEventToAnalytics("Main", action: "Click", label: "Post")
            let controller = Storyboards.Main.instantiatePostViewController()
            controller.objectId = object as? CRUDObjectId
            navigationController?.pushViewController(controller, animated: true)
        case .Event:
            trackEventToAnalytics("Main", action: "Click", label: "Post")
            let controller = Storyboards.Main.instantiateEventDetailsViewControllerId()
            controller.objectId = object as? CRUDObjectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        default:
            Log.debug?.message("Did select \(itemType)<\(object)>")
        }
    }
    
    func browseControllerDidChangeContent(controller: BrowseActionProducer) {
        Log.verbose?.message("\(controller) did change content")
    }
    
    func browseMapViewControllerCenterMapOnLocation(location: Location) {
        //crash searchbar.getter, should fix
//        self.searchbar.attributedText = self.searchBarAttributedText(self.searchString, searchString: nil, locationString: SearchFilter.currentFilter.locationName)
    }
    
    //MARK: - Search -
    
    lazy var searchbar: UITextField = { [unowned self] in
        let width = self.navigationController?.navigationBar.frame.size.width
        let searchBar = UITextField(frame: CGRectMake(0, 0, width! * 0.7, 32))
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIScheme.searchbarBgColor
        searchBar.borderStyle = UITextBorderStyle.RoundedRect
        searchBar.font = UIScheme.appRegularFontOfSize(16)
        searchBar.textColor = UIColor.whiteColor()
        let leftView: UIImageView = UIImageView(image: UIImage(named: "search_icon"))
        leftView.frame = CGRectMake(0.0, 0.0, leftView.frame.size.width + 5.0, leftView.frame.size.height);
        leftView.contentMode = .Center
        searchBar.leftView = leftView
        searchBar.leftViewMode = .Always
        searchBar.delegate = self
        let str = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName:UIColor(white: 255, alpha: 0.5),
            NSFontAttributeName: UIScheme.appRegularFontOfSize(16)])
        searchBar.attributedPlaceholder =  str
        return searchBar
        }()
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.presentSearchViewController(SearchFilter.currentFilter)
        return false
    }
    
    func presentSearchViewController(filter: SearchFilter) {
        self.searchbar.attributedText = nil
        self.searchString = nil
        SearchViewController.present(searchbar, presenter: self, filter: filter)
    }
    
    func searchViewControllerCancelSearch() {
        self.searchbar.attributedText = self.searchBarAttributedText(nil, searchString: nil, locationString: SearchFilter.currentFilter.locationName)
    }
    
    func searchViewControllerItemSelected(model: SearchItemCellModel?, searchString: String?, locationString: String?) {
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
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.communities = [model.objectID]
                    return f
                }
                applyDisplayMode(displayMode)
            case .People:
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.users = [model.objectID]
                    return f
                }
                applyDisplayMode(displayMode)                
            }
            
            self.searchbar.attributedText = self.searchBarAttributedText(model.title, searchString: searchString, locationString: locationString)
        }
    }
    
    func searchViewControllerLocationSelected(locationString: String?) {
        if let locationString = locationString {
            self.searchbar.attributedText = NSMutableAttributedString(string: locationString,
                attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        }
    }
    
    func searchViewControllerSearchStringSelected(searchString: String?, locationString: String?) {
        self.searchbar.attributedText = self.searchBarAttributedText(nil,
            searchString: searchString,
            locationString: locationString)
        childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
            var f = filter
            f.name = searchString
            return f
        }
        applyDisplayMode(displayMode)
    }
    
    func searchViewControllerHomeItemSelected(homeItem: HomeItem, locationString: String?) {
        self.searchbar.attributedText = self.searchBarAttributedText(nil,
            searchString: homeItem.displayString(),
            locationString: locationString)
    }
    
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?, searchString: String?, locationString: String?) {
        if let model = model {
            self.searchbar.attributedText = self.searchBarAttributedText(model.title, searchString: searchString, locationString: locationString)
            let itemType = model.itemType
            childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                var f = filter
                f.itemTypes = [ itemType ]
                return f
            }
            applyDisplayMode(displayMode)
        }
    }
    
    func searchBarAttributedText(modelTitle: String?, searchString: String?, locationString: String?) -> NSAttributedString {
        
        var str: NSMutableAttributedString = NSMutableAttributedString()
        var searchBarString: String = ""
        
        if let modelTitle = modelTitle {
            searchBarString = modelTitle
            self.searchString = modelTitle
        }
        
        if let searchString = searchString {
            searchBarString = "\(searchBarString) \(searchString)"
            self.searchString = searchBarString
        }
        
        if let locationString = locationString {
            searchBarString = "\(searchBarString) \(locationString)"
        }
        
        str = NSMutableAttributedString(string: searchBarString,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        if let locationString = locationString {
            let searchBarStringAsNSString: NSString = searchBarString
            
            str.addAttributes([NSForegroundColorAttributeName:UIColor(white: 1, alpha: 0.5)],
                range: searchBarStringAsNSString.rangeOfString(locationString))
        }
        
        return str
    }
}