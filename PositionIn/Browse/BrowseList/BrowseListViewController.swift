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

final class BrowseListViewController: UIViewController, BrowseActionProducer, BrowseModeDisplay, UpdateFilterProtocol {
    var excludeCommunityItems = false
    var shoWCompactCells: Bool = true
    var showCardCells: Bool = false
    var homeItem: HomeItem?
    private var dataRequestToken = InvalidationToken()

    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou {
        didSet {
            switch browseMode {
            case .ForYou:
                trackGoogleAnalyticsEvent("Main", action: "Click", label: "For You")
            case .New:
                trackGoogleAnalyticsEvent("Main", action: "Click", label: "New")
            }
        }
    }
    
    //hide separator lines
    var hideSeparatorLinesNearSegmentedControl: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        selectedItemType = .Unknown
        
        self.tableView.separatorStyle = self.showCardCells ? .None : .SingleLine
        self.topSeparatorLine.hidden = hideSeparatorLinesNearSegmentedControl
        self.bottomSeparatorLine.hidden = hideSeparatorLinesNearSegmentedControl
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topSeparatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
        self.bottomSeparatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let fromViewController = self.navigationController?.transitionCoordinator()?.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            if self.navigationController?.viewControllers.contains(fromViewController) == false {
                self.reloadData()
            }
        }

        //TODO: hot fix for distance 
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.tableView.reloadData()
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
            if self.isViewLoaded() {
                self.displayModeSegmentedControl.selectedSegmentIndex = 0
            }
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
            [unowned self] response in
            Log.debug?.value(response.items)

            var items: [FeedItem] = response.items
            if self.excludeCommunityItems {
                items = items.filter { $0.community == CRUDObjectInvalidId }
            }
            
            self.dataSource.setItems(self, feedItems: items)
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPointZero, animated: false)
            self.actionConsumer?.browseControllerDidChangeContent(self)
        }
    }
    
    @IBOutlet weak var topSeparatorLine: UIView!
    @IBOutlet weak var bottomSeparatorLine: UIView!
    
    @IBOutlet weak var topSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorHeightConstraint: NSLayoutConstraint!
    
    private lazy var dataSource: FeedItemDatasource = { [unowned self] in
        let dataSource = FeedItemDatasource(shouldShowDetailedCells: self.shoWCompactCells,
            showCardCells: self.showCardCells)
        dataSource.parentViewController = self
        return dataSource
        }()

    weak var actionConsumer: BrowseActionConsumer?
    
    @IBOutlet private(set) internal weak var tableView: UITableView!
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!
}
    
extension BrowseListViewController: ActionsDelegate {
    
    func like(item: FeedItem) {
        if (item.isLiked) {
            api().unlikePost(item.objectId).onSuccess{[weak self] in
                self?.reloadData()
            }
        }
        else {
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
                if model.item.type == .Post {
                    var cellHeight: CGFloat = 150
                    cellHeight = (model.imageURL != nil) ? (cellHeight + 80) : cellHeight

                    if let text = model.text {
                        let maxSize = CGSize(width: UIScreen.mainScreen().applicationFrame.size.width - 20, height: 80)
                        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)])
                        let rect = attrString.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                        let size = CGSizeMake(rect.size.width, rect.size.height)
                        
                        cellHeight += (size.height + 10)
                    }
                    
                    
                    return cellHeight
                    
                }
                else {
                    let height: CGFloat = showCompactCells ? 80.0 : 120.0
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