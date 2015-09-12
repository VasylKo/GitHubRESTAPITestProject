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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        
        fillMockItems()
        selectedItemType = .Inventory
    }
    
    var selectedItemType: ShopItem.WalletType = .Inventory {
        didSet{
            dataSource.setItems(items.filter{[unowned self] in $0.walletType == self.selectedItemType})
            tableView.reloadData()
        }
    }
    
    func fillMockItems() {
        let item1 = ShopItem(feedItem: FeedItem(nameTmp: "The Forest", detailsTmp: "Edward Rayan", textTmp: "9 miles", priceTmp: 12.0), walletType: ShopItem.WalletType.Inventory)
        let item4 = ShopItem(feedItem: FeedItem(nameTmp: "Albuquerque", detailsTmp: "Amber Tran", textTmp: "9 miles", priceTmp: 12.0), walletType: ShopItem.WalletType.Inventory)
        let item5 = ShopItem(feedItem: FeedItem(nameTmp: "World X1", detailsTmp: "Sharon Brewer", textTmp: "9 miles", priceTmp: 12.0), walletType: ShopItem.WalletType.Inventory)
        let text = map(NSDate()){dateFormatter.stringFromDate($0)}
        let item2 = ShopItem(feedItem: FeedItem(nameTmp: "Wizard of the Coast", detailsTmp: "Edward Rayan", textTmp: text ?? "01.02.2015", priceTmp: 123.23), walletType: ShopItem.WalletType.Sold)
        let item3 = ShopItem(feedItem: FeedItem(nameTmp: "Venus Poster", detailsTmp: "Arthur Anderson", textTmp: text ?? "01.02.2015", priceTmp: 214.32), walletType: ShopItem.WalletType.Purchased)
        items = [item1, item4, item5, item2, item3]
    }
    
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        let segmentMapping: [Int: ShopItem.WalletType] = [
            0: .Inventory,
            1: .Sold,
            2: .Purchased
        ]
        if let newFilterValue = segmentMapping[sender.selectedSegmentIndex]{
            selectedItemType = newFilterValue
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
    
    var items: [ShopItem] = []
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
            
            return  ProductListCell.reuseId()
        }
        
        override func nibCellsId() -> [String] {
            return [ProductListCell.reuseId()]
        }
        
        //        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? FeedTableCellModel,
        //                let actionProducer = parentViewController as? BrowseActionProducer,
        //                let actionConsumer = self.actionConsumer {
        //                    actionConsumer.browseController(actionProducer, didSelectItem: model.objectID, type: model.itemType, data: model.data)
        //            }
        //        }
        //
        
        func setItems(shopItems: [ShopItem]) {
            models = shopItems.map { self.modelFactory.modelsForItem($0) }
        }
        
        //        private var actionConsumer: BrowseActionConsumer? {
        //            return flatMap(parentViewController as? BrowseActionProducer) { $0.actionConsumer }
        //
        //        }
        
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = WalletCellFactory()
    }
    
    
}
