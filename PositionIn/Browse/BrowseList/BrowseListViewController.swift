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
        dataSource.configureTable(tableView)
    }
    
    var filter: Filter = .All {
        didSet {
            tableView?.reloadData()
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
    
    private lazy var dataSource: ProductListDataSource = {
        let dataSource = ProductListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

    weak var actionConsumer: BrowseActionConsumer?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!

}


extension BrowseListViewController {
    internal class ProductListDataSource: TableViewDataSource {
                
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 100
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            if indexPath.row % 4 == 0 {
                return  EventListCell.reuseId()
            }
            
            if indexPath.row % 3 == 0 {
                return PromotionListCell.reuseId()
            }
            
            if indexPath.row % 2 == 0 {
                return PostListCell.reuseId()
            }
            
            return ListProductCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            if indexPath.row % 4 == 0 {
                return TableViewCellEventModel(title: "Art Gallery", date: NSDate(), info: "45 People are attending", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            }
            
            if indexPath.row % 3 == 0 {
                return TableViewCellPromotionModel(title: "Arts & Crafts Summer Sale", author: "The Sydney Art Store", discount: "Save 80%", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            }
            
            if indexPath.row % 2 == 0 {
                return TableViewCellPostModel(title: "Betty Wheeler", info: "Lovely day to go golfing", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            }
            
            return TableViewCellProductModel(title: "The forest", owner: "Edwarn Ryan", distance: 0.09, imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png", price: 99.8)
        }
        
        override func nibCellsId() -> [String] {
            return [ListProductCell.reuseId(), EventListCell.reuseId(), PromotionListCell.reuseId(), PostListCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let browseController = parentViewController as? BrowseActionProducer,
               let actionConsumer = browseController.actionConsumer {
                actionConsumer.browseController(browseController, didSelectPost: Post(objectId: CRUDObjectInvalidId))
            }
        }
    }
}