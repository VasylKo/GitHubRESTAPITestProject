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
        dataSource.setItems([])
        tableView?.reloadData()
        
        guard let userId: CRUDObjectId = api().currentUserId() else {
            return
        }
        
        switch browseMode {
        case .Purchases:
            api().getOrders(userId, reason: "bought").onSuccess { [weak self] (response : CollectionResponse<Order>) in
                let items = response.items.map { item -> Order in
                    item.entityDetails?.name = item.entityDetails?.name ?? NSLocalizedString("Donation to KRCS")
                    return item
                }
                
                self?.dataSource.setItems(items)
                self?.tableView?.reloadData()
            }
        case .MyDonations:
            api().getDonations(userId).onSuccess { [weak self] (response : CollectionResponse<Order>) in
                self?.dataSource.setItems(response.items)
                self?.tableView?.reloadData()
            }
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
        private let modelFactory = WalletsCellFactory()
        
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
            
            guard let walletViewController = parentViewController as? WalletViewController else {
                return
            }
            
            switch walletViewController.browseMode {
            case .Purchases:
                let controller =  Storyboards.Main.instantiateOrderDetailsViewControllerId()
                //controller.donation = model.donation
                walletViewController.navigationController?.pushViewController(controller, animated: true)
            case .MyDonations:
                let controller =  Storyboards.Main.instantiateDonationDetailsViewControllerId()
                //controller.donation = model.donation
                walletViewController.navigationController?.pushViewController(controller, animated: true)
            }
        }

        func setItems(orders: [Order]) {
            models = orders.map { modelFactory.walletModelsForItem($0) }
        }
    }
}