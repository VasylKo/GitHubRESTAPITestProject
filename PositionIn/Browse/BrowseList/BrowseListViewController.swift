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
            return ListProductCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return TableViewCellTextModel(title: "\(Float(indexPath.row) / 100.0) miles")
        }
        
        override func nibCellsId() -> [String] {
            return [ListProductCell.reuseId()]
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