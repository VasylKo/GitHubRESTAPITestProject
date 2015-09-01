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

final class BrowseListViewController: UIViewController, BrowseActionProducer {
    
    let shoWCompactCells: Bool = true
    private var dataRequestToken = InvalidationToken()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        selectedItemType = FeedItem.ItemType.Unknown
        
    }
    
    var filter = SearchFilter.currentFilter {
        didSet {
            if isViewLoaded() {
                getFeedItems(filter)
            }
        }
    }
    
    var selectedItemType: FeedItem.ItemType = .Unknown {
        didSet {
            var f = filter
            f.itemTypes = [selectedItemType]
            filter = f
        }
    }
    
    private func getFeedItems(searchFilter: SearchFilter, page: APIService.Page = APIService.Page()) {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        api().getFeed(searchFilter, page: page).onFailure { error in
            Log.error?.value(error)
        }.onSuccess(token: dataRequestToken) { [weak self] response in
            Log.debug?.value(response.items)
            Log.debug?.value(searchFilter.itemTypes)
            
            Log.debug?.value(self?.selectedItemType)
            if let strongSelf = self,
               let itemTypes = searchFilter.itemTypes
               where contains(itemTypes, strongSelf.selectedItemType) {
                strongSelf.dataSource.setItems(response.items)
                strongSelf.tableView.reloadData()
                strongSelf.tableView.setContentOffset(CGPointZero, animated: false)
            }            
        }
    }
    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        if let newFilterValue = FeedItem.ItemType(rawValue: sender.selectedSegmentIndex) {
            selectedItemType = newFilterValue
        }
    }
    
    private lazy var dataSource: FeedItemDatasource = {
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
                actionConsumer.browseController(actionProducer, didSelectItem: model.objectID, type: model.itemType)
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