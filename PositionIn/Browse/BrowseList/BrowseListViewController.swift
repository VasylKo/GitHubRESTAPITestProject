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

final class BrowseListViewController: UIViewController, BrowseActionProducer, BrowseModeDisplay, SearchFilterProtocol {
    var excludeCommunityItems = false
    var shoWCompactCells: Bool = true
    private var dataRequestToken = InvalidationToken()

    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        selectedItemType = .Unknown
    }
        
    var filter = SearchFilter.currentFilter {
        didSet {
            if isViewLoaded() {
                getFeedItems(filter)
            }
        }
    }

    func applyFilterUpdate(update: SearchFilterUpdate, canAffect: Bool) {
        canAffectFilter = canAffect
        
        filter = update(filter)
    }
    
    private var canAffectFilter = true
    
    var selectedItemType: FeedItem.ItemType = .Unknown {
        didSet {
            var f = filter
            if (canAffectFilter) {
                f.itemTypes = [selectedItemType]
            }
            else {
//                contains(itemTypes, strongSelf.selectedItemType)
                if filter.itemTypes?.first == selectedItemType || selectedItemType == .Unknown {
                    filter = f
                }
                else {
                    self.dataSource.setItems([])
                    self.tableView.reloadData()
                }
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
        let request: Future<CollectionResponse<FeedItem>,NSError>
        switch browseMode {
        case .ForYou:
            request = api().forYou(searchFilter, page: page)
        case .New:
            request = api().getFeed(searchFilter, page: page)
        }
        request.onSuccess(token: dataRequestToken) {
            [weak self] response in
            Log.debug?.value(response.items)
            if let strongSelf = self,
               let itemTypes = searchFilter.itemTypes
                //TODO: need discuss this moment
               where contains(itemTypes, strongSelf.selectedItemType) || strongSelf.selectedItemType == .Unknown  {
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
    }
    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        let segmentMapping: [Int: FeedItem.ItemType] = [
            0: .Unknown,
            1: .Item,
            2: .Event,
            3: .Promotion,
            4: .Post,
        ]
        if let newFilterValue = segmentMapping[sender.selectedSegmentIndex] {
            selectedItemType = newFilterValue
        }
    }
    
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
            return count(models)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return count(models[section])
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
            return flatMap(parentViewController as? BrowseActionProducer) { $0.actionConsumer }

        }
        
        let showCompactCells: Bool
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
        
    }

}