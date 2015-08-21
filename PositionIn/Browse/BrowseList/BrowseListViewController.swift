//
//  BrowseListViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class BrowseListViewController: UIViewController, BrowseActionProducer {
    
    let shoWCompactCells: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        filter = .ShowAll
    }
    
    //        APIService.getFeed(APIService.Page()).onSuccess{ [unowned self] (response: CollectionResponse<FeedItem>) -> () in
    //            self.items = response.items
    //        }

    
    var filter: Filter = .ShowAll {
        didSet {
            let filteredItems: [FeedItem]
            
            switch filter {
            case .ShowAll:
                filteredItems = items
            case .ShowPosts:
                filteredItems = items.filter { $0.type == FeedItem.self.Type.Post }
            case .ShowEvents:
               filteredItems =  items.filter { $0.type == FeedItem.self.Type.Event }
            case .ShowPromotions:
                filteredItems = items.filter { $0.type == FeedItem.self.Type.Promotion }
            case .ShowEvents:
                filteredItems = items.filter { $0.type == FeedItem.self.Type.Event }
            }
            dataSource.setItems(filteredItems)
            tableView.reloadData()
            tableView.setContentOffset(CGPointZero, animated: false)
        }
    }
    
    enum Filter: Int {
        case ShowAll = 0
        case ShowProducts
        case ShowEvents
        case ShowPromotions
        case ShowPosts
    }

    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        if let newFilterValue = Filter(rawValue: sender.selectedSegmentIndex) {
            filter = newFilterValue
        }
    }
    
    private lazy var dataSource: FeedItemDatasource = {
        let dataSource = FeedItemDatasource(shouldShowDetailedCells: self.shoWCompactCells)
        dataSource.parentViewController = self
        return dataSource
        }()

    weak var actionConsumer: BrowseActionConsumer?
    var items: [FeedItem] = []
    
    @IBOutlet private weak var tableView: UITableView!
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
            model.type
            return TableViewCell.reuseId()
        }
        
        override func nibCellsId() -> [String] {
            return [ProductListCell.reuseId(), EventListCell.reuseId(), PromotionListCell.reuseId(), PostListCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let browseController = parentViewController as? BrowseActionProducer,
               let actionConsumer = browseController.actionConsumer {
                actionConsumer.browseController(browseController, didSelectPost: Post(objectId: CRUDObjectInvalidId))
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
        
        let showCompactCells: Bool
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
        
    }

}