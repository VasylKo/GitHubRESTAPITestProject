//
//  BrowseListViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

class BrowseListViewController: UIViewController, BrowseActionProducer, BrowseModeDisplay, UpdateFilterProtocol {
    var excludeCommunityItems = false
    var shoWCompactCells: Bool = true
    var showCardCells: Bool = false
    var homeItem: HomeItem?
    private var dataRequestToken = InvalidationToken()

    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou {
        didSet {
            switch browseMode {
            case .ForYou:
                trackEventToAnalytics("Main", action: "Click", label: "For You")
            case .New:
                trackEventToAnalytics("Main", action: "Click", label: "New")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        self.setupUI()
    }
    
    
    func setupUI() {
        selectedItemType = .Unknown

        if (UIScreen.mainScreen().bounds.size.width == 375) { //check if iphone 6
            self.bannerButton.setBackgroundImage(UIImage(named: "pledge_banner_iphone6"), forState: .Normal)
        }
        
        if homeItem == .GiveBlood {
            self.bannerButton.hidden = false
            self.tableViewBottomContraint.constant = 60
        }
        else {
            self.bannerButton.hidden = true
            self.tableViewBottomContraint.constant = 0
            self.view.setNeedsUpdateConstraints()
        }
        
        self.tableView.separatorStyle = self.showCardCells ? .None : .SingleLine
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Send analytics
        if let homeItem = homeItem {
            trackScreenToAnalytics(AnalyticsLabels.labelForHomeItem(homeItem, suffix: "List"))
        }
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let fromViewController = self.navigationController?.transitionCoordinator()?.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            if self.navigationController?.viewControllers.contains(fromViewController) == false {
                self.reloadData()
            }
        }
    }
    
    var filter = SearchFilter.currentFilter {
        didSet {
            if isViewLoaded() {
                getFeedItems(filter)
            }
        }
    }

    func applyFilterUpdate(update: SearchFilterUpdate) {
        canAffectFilter = false
        filter = update(filter)
    }
    
    var canAffectFilter = true {
        didSet {
            selectedItemType = .Unknown
        }
    }
    
    var selectedItemType: FeedItem.ItemType = .Unknown {
        didSet {
            var f = filter
            if (canAffectFilter) {
                f.itemTypes = [selectedItemType]
            }
            filter = f
        }
    }

    func reloadData() {
        getFeedItems(filter)
    }
    
    private func getFeedItems(searchFilter: SearchFilter, page: APIService.Page = APIService.Page()) {
        
        Log.debug?.trace()
        Log.debug?.value(self)
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        
        //MARK: should refactor
        
        var homeItem = HomeItem.Unknown
        if let homeItemUnwrapped = self.homeItem {
            homeItem = homeItemUnwrapped
        }
        let request: Future<CollectionResponse<FeedItem>,NSError> = api().getAll(homeItem, seachFilter: self.filter)
        
        request.onSuccess(dataRequestToken.validContext) {
            [weak self] response in
            
            guard let strongSelf = self else {
                return
            }
            
            Log.debug?.value(response.items)
            
            var items: [FeedItem] = response.items
            if strongSelf.excludeCommunityItems {
                items = items.filter { $0.community == CRUDObjectInvalidId }
            }
            
            strongSelf.dataSource.setItems(strongSelf, feedItems: items)
            strongSelf.tableView.reloadData()
            strongSelf.tableView.setContentOffset(CGPointZero, animated: false)
            strongSelf.actionConsumer?.browseControllerDidChangeContent(strongSelf)
        }
    }
    
    private lazy var dataSource: FeedItemDatasource = { [unowned self] in
        let dataSource = FeedItemDatasource(shouldShowDetailedCells: self.shoWCompactCells,
            showCardCells: self.showCardCells)
        dataSource.parentViewController = self
        return dataSource
        }()
    
    weak var actionConsumer: BrowseActionConsumer?
    
    
    @IBAction func bannerTapped(sender: AnyObject) {
        let url: NSURL? = NSURL(string: "http://www.pledge25kenya.org/")
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBOutlet weak var tableViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerButton: UIButton!
    @IBOutlet private(set) internal weak var tableView: UITableView!
}

extension BrowseListViewController: ActionsDelegate {
    
    func like(item: FeedItem) {
        item.name = ""
        if (item.isLiked) {
            item.isLiked = false
            item.numOfLikes?--
            tableView.reloadData()
            api().unlikePost(item.objectId).onSuccess{[weak self] in
                self?.reloadData()
            }
        }
        else {
            item.isLiked = true
            item.numOfLikes?++
            tableView.reloadData()
            api().likePost(item.objectId).onSuccess{[weak self] in
                self?.reloadData()
            }
        }
    }
}

extension BrowseListViewController {
    internal class FeedItemDatasource: TableViewDataSource {
        
        init(shouldShowDetailedCells detailed: Bool, showCardCells: Bool) {
            showCompactCells = detailed
            self.showCardCells = showCardCells
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return models.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return models[section].count
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return models[indexPath.section][indexPath.row]
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            let model = self.tableView(tableView, modelForIndexPath: indexPath)
            return showCompactCells ? modelFactory.compactCellReuseIdForModel(model, showCardCells: self.showCardCells) : modelFactory.detailCellReuseIdForModel(model)
        }
        
        override func nibCellsId() -> [String] {
            if showCompactCells {
                return modelFactory.compactCellsReuseId()
            } else {
                return modelFactory.detailedCellsReuseId()
            }
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? FeedTableCellModel,
                let actionProducer = parentViewController as? BrowseActionProducer,
                let actionConsumer = self.actionConsumer {
                    actionConsumer.browseController(actionProducer, didSelectItem: model.item.objectId, type: model.item.type, data: model.data)
            }
        }
        
        func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? CompactFeedTableCellModel {
                if model.item.type == .Post || model.item.type == .News {
                    var cellHeight: CGFloat = 125
                    cellHeight = (model.imageURL != nil) ? (cellHeight + 160) : cellHeight
                    
                    if let text = model.text {
                        let maxSize = CGSize(width: UIScreen.mainScreen().applicationFrame.size.width - 80, height: CGFloat(MAXFLOAT))
                        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)])
                        let rect = attrString.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                        let size = CGSizeMake(rect.size.width, rect.size.height)
                        
                        cellHeight += (size.height + 17)
                    }   
                    return cellHeight
                }
                else {
                    let height: CGFloat = showCompactCells ? 75.0 : 100.0
                    return height
                }
            }
            return 0
        }
        
        func setItems(delegate: ActionsDelegate, feedItems: [FeedItem]) {
            if showCompactCells {
                let list =  feedItems.reduce([]) { models, feedItem  in
                    return models + self.modelFactory.compactModelsForItem(delegate, feedItem: feedItem)
                }
                models = [ list ]
            } else {
                models = feedItems.map { self.modelFactory.detailedModelsForItem($0) }
            }
        }
        
        private var actionConsumer: BrowseActionConsumer? {
            return (parentViewController as? BrowseActionProducer).flatMap { $0.actionConsumer }
        }
        
        let showCardCells: Bool
        let showCompactCells: Bool
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
    }
}