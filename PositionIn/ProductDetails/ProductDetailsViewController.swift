//
//  ProductDetailsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol ProductDetailsActionConsumer {
    func executeAction(action: ProductDetailsViewController.ProductDetailsAction)
}

final class ProductDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Product", comment: "Product details: title")
        dataSource.items = productAcionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    
    private func reloadData() {
        self.infoLabel.text = NSLocalizedString("Calculating...", comment: "Distance calculation process")
        nameLabel.text = author?.title
        switch (objectId, author) {
        case (.Some(let objectId), .Some(let author) ):
            api().getUserProfile(author.objectId).flatMap { (profile: UserProfile) -> Future<Product, NSError> in
                let page = APIService.Page()
                return api().getProduct(objectId, inShop: profile.defaultShopId)
            }.onSuccess { [weak self] product in
                self?.didReceiveProductDetails(product)
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveProductDetails(product: Product) {
        headerLabel.text = product.name
        detailsLabel.text = product.text
        priceLabel.text = map(product.price) { "$\($0)" }
        let url = product.photos?.first?.url
        let image = product.category?.productPlaceholderImage()
        productImageView.setImageFromURL(url, placeholder: image)
        if let coordinates = product.location?.coordinates {
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(token: locationRequestToken) {
                [weak self] distance in
                let format = NSLocalizedString("%.2f km", comment: "Distance format")
                self?.infoLabel.text = String(format: format, distance)
            }
        }
    }
    
    var objectId: CRUDObjectId?
    var author: ObjectInfo?
    
    private var locationRequestToken = InvalidationToken()
    
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
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension ProductDetailsViewController {
    enum ProductDetailsAction: Printable {
        case Buy, ProductInventory, SellerProfile, SendMessage
        
        var description: String {
            switch self {
            case .Buy:
                return "Buy"
            case .ProductInventory:
                return "Product Inventory"
            case .SellerProfile:
                return "Seller profile"
            case .SendMessage:
                return "Send message"
            }
        }
    }
    
    
    struct ProductActionItem {
        let title: String
        let image: String
        let action: ProductDetailsAction
    }
}

extension ProductDetailsViewController: ProductDetailsActionConsumer {
    func executeAction(action: ProductDetailsAction) {
        let segue: ProductDetailsViewController.Segue
        switch action {
        case .Buy:
            segue = .ShowBuyScreen
        case .ProductInventory:
            segue = .ShowProductInventory
        case .SellerProfile:
            segue = .ShowSellerProfile
        default:
            Log.warning?.message("Unhandled action: \(action)")
            return
        }
        performSegue(segue)
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
            return ActionCell.reuseId()
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
            return [ActionCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = items[indexPath.section][indexPath.row]
            if let actionConsumer = parentViewController as? ProductDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
        
    }
}


extension ItemCategory {
    func productPlaceholderImage() -> UIImage {
        switch self {
        case .Unknown:
            fallthrough
        default:
            return UIImage(named: "BrowseModeList")!
        }
    }
}