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

    override func viewDidLoad() {
        super.viewDidLoad()
//        APIService.getFeed(APIService.Page()).onSuccess{ [unowned self] (response: CollectionResponse<FeedItem>) -> () in
//            self.items = response.items
//        }
        
        dataSource.configureTable(tableView)
    }
    
    var filter: Filter = .All {
        didSet {
            if let datasourse = dataSource as? GeneralListDataSource {
            switch filter {
            case .All:
                datasourse.filteredItems = items
            case .Posts:
                datasourse.filteredItems = items.filter({$0.type == FeedItem.self.Type.Post})
            case .Products:
               datasourse.filteredItems = items.filter({$0.type == FeedItem.self.Type.Item})
            case .Promotions:
                datasourse.filteredItems = items.filter({$0.type == FeedItem.self.Type.Promotions})
            case .Events:
                datasourse.filteredItems = items.filter({$0.type == FeedItem.self.Type.Event})
            }
            dataSource = GeneralListDataSource()
            dataSource.configureTable(tableView)
            tableView.setContentOffset(CGPointZero, animated: true)
            }
        }
    }
    
    enum Filter: Int {
        case All = 0
        case Products
        case Events
        case Promotions
        case Posts
    }

    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        if let newFilterValue = Filter(rawValue: sender.selectedSegmentIndex) {
            filter = newFilterValue
        }
    }
    
    private lazy var dataSource: TableViewDataSource = {
        let dataSource = GeneralListDataSource()
        dataSource.filteredItems = self.items
        dataSource.parentViewController = self
        return dataSource
        }()

    weak var actionConsumer: BrowseActionConsumer?
    var items: [FeedItem] = []
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!

}


extension BrowseListViewController {
    internal class GeneralListDataSource: TableViewDataSource {
                
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredItems.count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return BrowseListCellsProvider.reuseIdFor(feedItem: filteredItems[indexPath.row])
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return BrowseListCellsProvider.modelFor(feedItem: filteredItems[indexPath.row])
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
        
        var filteredItems: [FeedItem] = []
    }

}