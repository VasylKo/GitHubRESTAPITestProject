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
        
        self.topSeparatorLine.hidden = hideSeparatorLinesNearSegmentedControl
        self.bottomSeparatorLine.hidden = hideSeparatorLinesNearSegmentedControl
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topSeparatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
        self.bottomSeparatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
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
//            else if (filter.itemTypes!.filter { $0 == FeedItem.ItemType.Unknown }.count == 0)
//                || selectedItemType != FeedItem.ItemType.Unknown {
//                self.dataSource.setItems([])
//                self.tableView.reloadData()
//            }
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
        
        var homeItem = HomeItem.Unknown
        if let tempHomeItem = searchFilter.homeItemType {
            homeItem = tempHomeItem
        }
        let request: Future<CollectionResponse<FeedItem>,NSError> = api().getAll(homeItem)
        
//        switch browseMode {
//        case .ForYou:
//            request = api().forYou(searchFilter, page: page)
//        case .New:
//            request = api().getFeed(searchFilter, page: page)
//        }
        request.onSuccess(dataRequestToken.validContext) {
            [weak self] response in
            Log.debug?.value(response.items)
            guard let strongSelf = self
//                let itemTypes = searchFilter.itemTypes{
//                //TODO: need discuss this moment
//                where itemTypes.contains(strongSelf.selectedItemType) || strongSelf.selectedItemType == .Unknown 
                else {
                    return
            }

            var items: [FeedItem] = response.items
            if strongSelf.excludeCommunityItems {
                items = items.filter { $0.community == CRUDObjectInvalidId }
            }
            strongSelf.dataSource.setItems(items)
            strongSelf.tableView.reloadData()
            strongSelf.tableView.setContentOffset(CGPointZero, animated: false)
            strongSelf.actionConsumer?.browseControllerDidChangeContent(strongSelf)
        }
    }
    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
//        let segmentMapping: [Int: FeedItem.ItemType] = [
//            0: .Unknown,
//            1: .Item,
//            2: .Event,
//            3: .Promotion,
//            4: .Post,
//        ]
//        if let newFilterValue = segmentMapping[sender.selectedSegmentIndex] {
//            selectedItemType = newFilterValue
//        }
    }
    
    @IBOutlet weak var topSeparatorLine: UIView!
    @IBOutlet weak var bottomSeparatorLine: UIView!
    
    @IBOutlet weak var topSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorHeightConstraint: NSLayoutConstraint!
    
    private lazy var dataSource: FeedItemDatasource = { [unowned self] in
        let dataSource = FeedItemDatasource(shouldShowDetailedCells: self.shoWCompactCells)
        dataSource.parentViewController = self
        return dataSource
        }()

    weak var actionConsumer: BrowseActionConsumer?
    
    @IBOutlet private(set) internal weak var tableView: UITableView!
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!
}

extension BrowseListViewController {
    internal class FeedItemDatasource: TableViewDataSource {
        
        init(shouldShowDetailedCells detailed: Bool) {
            showCompactCells = detailed
        }
                
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = showCompactCells ? 80.0 : 120.0
            super.configureTable(tableView)
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
            return showCompactCells ? modelFactory.compactCellReuseIdForModel(model) : modelFactory.detailCellReuseIdForModel(model)
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
                actionConsumer.browseController(actionProducer, didSelectItem: model.objectID, type: model.itemType, data: model.data)
            }
        }
        
        
        func setItems(feedItems: [FeedItem]) {
            if showCompactCells {
                let list =  feedItems.reduce([]) { models, feedItem  in
                    return models + self.modelFactory.compactModelsForItem(feedItem)
                }
                models = [ list ]
            } else {
                models = feedItems.map { self.modelFactory.detailedModelsForItem($0) }
            }

        }
        
        private var actionConsumer: BrowseActionConsumer? {
            return (parentViewController as? BrowseActionProducer).flatMap { $0.actionConsumer }

        }
        
        let showCompactCells: Bool
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
        
    }
}