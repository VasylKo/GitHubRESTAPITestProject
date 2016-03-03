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
        case Purchases, MyDonations
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView?
    
    // MARK: - Private variables
    private var browseMode: BrowseMode = .Purchases {
        didSet {
            reloadData()
            switch browseMode {
            case .Purchases:
                trackGoogleAnalyticsEvent("Wallet", action: "Click", label: "Purchases")
            case .MyDonations:
                trackGoogleAnalyticsEvent("Wallet", action: "Click", label: "MyDonations")
            }
        }
    }
    
    private lazy var dataSource: WalletItemDatasource = { [weak self] in
        let dataSource = WalletItemDatasource()
        if let strongSelf = self {
            dataSource.parentViewController = strongSelf
        }
        return dataSource
    }()
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableView = tableView {
            dataSource.configureTable(tableView)
        }
        browseMode = .Purchases
    }

    // MARK: - Private functions
    private func reloadData() {
        let items = mockData(browseMode)
        dataSource.setItems(items)
        tableView?.reloadData()
    }
    
    private func mockData(mode: BrowseMode) -> [FeedItem] {
        let dateText = Optional(NSDate()).map{dateFormatter.stringFromDate($0)}
        switch mode {
        case .Purchases:
            return  [
                FeedItem(name: "The Forest", details: "Edward Rayan", text: "9 miles", price: 12.0),
                FeedItem(name: "Albuquerque", details: "Amber Tran", text: "9 miles", price: 12.0),
                FeedItem(name: "World X1", details: "Sharon Brewer", text: "9 miles", price: 12.0)
            ]
        case .MyDonations:
            return [
                FeedItem(name: "Wizard of the Coast", details: "Edward Rayan", text: dateText ?? "01.02.2015", price: 123.23)
            ]
        }
    }

    // MARK: - Actions
    @IBAction func displayModeSegmentedControlChanged(sender: UISegmentedControl) {
        let segmentMapping: [Int: BrowseMode] = [
            0: .Purchases,
            1: .MyDonations,
        ]
        if let newFilterValue = segmentMapping[sender.selectedSegmentIndex]{
            browseMode = newFilterValue
        }
    }
}

extension WalletViewController {
    internal class WalletItemDatasource: TableViewDataSource {
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return (models).count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return models[section].count
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
    }
}