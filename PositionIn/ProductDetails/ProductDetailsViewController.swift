//
//  ProductDetailsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class ProductDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.items = productAcionItems()
        dataSource.configureTable(actionTableView)
    }
    
    
    private lazy var dataSource: ProductDetailsDataSource = {
        let dataSource = ProductDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
    }()
    
    
    private func productAcionItems() -> [[ProductActionItem]] {
        return [
            [ // 0 section
                ProductActionItem(title: NSLocalizedString("Buy Product", comment: "Product action: Buy Product"), image: "MainMenuMessages", action: .Buy),
                ],
            [ // 1 section
                ProductActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"), image: "MainMenuMessages", action: .SendMessage),
                ProductActionItem(title: NSLocalizedString("Product Inventory", comment: "Product action: Product Inventory"), image: "MainMenuMessages", action: .ProductInventory),
                ProductActionItem(title: NSLocalizedString("Seller Profile", comment: "Product action: Seller Profile"), image: "MainMenuMessages", action: .SellerProfile),
                ],
        ]
        
    }
    
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension ProductDetailsViewController {
    enum ProductDetailsAction {
        case Buy, ProductInventory, SellerProfile, SendMessage
    }
    
    struct ProductActionItem {
        let title: String
        let image: String
        let action: ProductDetailsAction
    }
}

extension ProductDetailsViewController {
    internal class ProductDetailsDataSource: TableViewDataSource {        
        
        var items: [[ProductActionItem]] = []
        
        override func configureTable(tableView: UITableView) {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            super.configureTable(tableView)
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ProductActionCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = items[indexPath.section][indexPath.row]
            let model = TableViewCellImageTextModel(title: item.title, imageName: item.image)
            return model
        }
        
        @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 1 {
                return 50
            }
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        override func nibCellsId() -> [String] {
            return [ProductActionCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = items[indexPath.section][indexPath.row]
        }

    }
}


