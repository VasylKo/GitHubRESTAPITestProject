//
//  WalletViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 11/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class WalletViewController: BesideMenuViewController {
    enum BrowseMode {
        case Inventory, Sold, Purchased
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        browseMode = .Inventory
    }
    
    func reloadData() {
        let items = mockData(browseMode)
        dataSource.setItems(items)
        tableView.reloadData()
    }
    
    var browseMode: BrowseMode = .Inventory {
        didSet{
            reloadData()
        }
    }
    
    func mockData(mode: BrowseMode) -> [FeedItem] {
        let dateText = map(NSDate()){dateFormatter.stringFromDate($0)}
        switch mode {
        case .Inventory:
            return  [
                FeedItem(name: "The Forest", details: "Edward Rayan", text: "9 miles", price: 12.0),
                FeedItem(name: "Albuquerque", details: "Amber Tran", text: "9 miles", price: 12.0),
                FeedItem(name: "World X1", details: "Sharon Brewer", text: "9 miles", price: 12.0)
            ]
        case .Sold:
            return [
                FeedItem(name: "Wizard of the Coast", details: "Edward Rayan", text: dateText ?? "01.02.2015", price: 123.23)
            ]
        case .Purchased:
            return [
                FeedItem(name: "Venus Poster", details: "Arthur Anderson", text: dateText ?? "01.02.2015", price: 214.32)
            ]
        }
    }
    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        let segmentMapping: [Int: BrowseMode] = [
            0: .Inventory,
            1: .Sold,
            2: .Purchased
        ]
        if let newFilterValue = segmentMapping[sender.selectedSegmentIndex]{
            browseMode = newFilterValue
        }
    }
    
    private lazy var dataSource: WalletItemDatasource = { [unowned self] in
        let dataSource = WalletItemDatasource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
        }()
    
    @IBOutlet private(set) internal weak var tableView: UITableView!
    @IBOutlet private weak var displayModeSegmentedControl: UISegmentedControl!
    
}


extension WalletViewController {
    
    internal class WalletItemDatasource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
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
            return modelFactory.walletReuseIdForModel(model)
        }
        
        override func nibCellsId() -> [String] {
            return modelFactory.walletReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        
        func setItems(feedItems: [FeedItem]) {
            models = feedItems.map { self.modelFactory.walletModelsForItem($0) }
        }
        
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
    }
    
    
}
