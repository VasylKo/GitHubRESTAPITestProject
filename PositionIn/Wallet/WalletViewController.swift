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
                trackEventToAnalytics("Wallet", action: "Click", label: "Purchases")
            case .MyDonations:
                trackEventToAnalytics("Wallet", action: "Click", label: "MyDonations")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.walletList)
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
                self?.dataSource.setItems(response.items)
                self?.tableView?.reloadData()
                
                //Send event to analytic
                trackEventToAnalytics(AnalyticCategories.wallet, action: AnalyticActios.purchased, value: NSNumber(integer: response.items.count))
            }
        case .MyDonations:
            api().getDonations(userId).onSuccess { [weak self] (response : CollectionResponse<Order>) in
                
                //Send event to analytic
                trackEventToAnalytics(AnalyticCategories.wallet, action: AnalyticActios.donations, value: NSNumber(integer: response.items.count))
                
                // FIXME: This hack should be removed when BE return entityDetails
                let items = response.items.map { item -> Order in
                    if item.entityDetails?.name == nil {
                        var entityDetails = Product()
                        entityDetails.objectId = CRUDObjectInvalidId
                        entityDetails.name = NSLocalizedString("Donation to KRCS")
                        item.entityDetails = entityDetails
                    }
                    return item
                }
                
                
                self?.dataSource.setItems(items)
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
            
            guard let walletViewController = parentViewController as? WalletViewController,
                model = models[indexPath.section][indexPath.row] as? ComapctBadgeFeedTableCellModel else {
                return
            }
            
            switch walletViewController.browseMode {
            case .Purchases:
                let controller = Storyboards.Main.instantiateBoughtProductDetailsViewControllerId()
                controller.product = model.item as? Order
                walletViewController.navigationController?.pushViewController(controller, animated: true)
            case .MyDonations:
                let controller = Storyboards.Main.instantiateDonationDetailsViewControllerId()
                controller.donation = model.item as? Order
                walletViewController.navigationController?.pushViewController(controller, animated: true)
            }
        }

        func setItems(orders: [Order]) {
            models = orders.map { modelFactory.walletModelsForItem($0) }
        }
    }
}