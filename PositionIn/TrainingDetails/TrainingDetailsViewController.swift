//
//  TrainingDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 04/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures
//
//protocol ProductDetailsActionConsumer {
//    func executeAction(action: ProductDetailsViewController.ProductDetailsAction)
//}

final class TrainingDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Training", comment: "Training details: title")
        dataSource.items = trainingActionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let orderController = segue.destinationViewController  as? OrderViewController {
            orderController.product = self.product
        }
        if let profileController = segue.destinationViewController  as? UserProfileViewController,
            let userId = author?.objectId {
                profileController.objectId = userId
        }
    }
    
    private func reloadData() {
        self.infoLabel.text = NSLocalizedString("Calculating...", comment: "Distance calculation process")
        switch (objectId, author) {
        case (.Some(let objectId), .Some(let author) ):
            api().getUserProfile(author.objectId).flatMap { (profile: UserProfile) -> Future<Product, NSError> in
                return api().getTrainingDetails(objectId)
                }.onSuccess { [weak self] product in
                    self?.didReceiveProductDetails(product)
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveProductDetails(product: Product) {
        self.product = product
        headerLabel.text = product.name
        detailsLabel.text = product.text?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        if let price = product.price {
            priceLabel.text = "\(Int(price)) KSH"
        }
        
        if let name = author?.title {
            nameLabel.text = name
        }
        
        //        temporary decision
        //        priceLabel.text = product.price.map {
        //            let newValue = $0 as Float
        //            return AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""}
        
        let imageURL: NSURL?
        
        if let urlString = product.imageURLString {
            imageURL = NSURL(string:urlString)
        } else {
            imageURL = nil
        }
        
        let image = UIImage(named: "trainings_placeholder")
        
        productImageView.setImageFromURL(imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
            }
        }
    }
    
    var objectId: CRUDObjectId?
    var author: ObjectInfo?
    
    private var product: Product?
    private var locationRequestToken = InvalidationToken()
    
    private lazy var dataSource: TrainingDetailsDataSource = { [unowned self] in
        let dataSource = TrainingDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func trainingActionItems() -> [[TrainingActionItem]] {
        return [
            [ // 0 section
                TrainingActionItem(title: NSLocalizedString("Sign Up", comment: "Product action: Buy Product"),
                    image: "productBuyProduct",
                    action: .Buy),
            ],
            [ // 1 section
                TrainingActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"),
                    image: "productSendMessage", action: .SendMessage),
                TrainingActionItem(title: NSLocalizedString("Organizer Profile", comment: "Product action: Seller Profile"),
                    image: "productSellerProfile", action: .SellerProfile),
                TrainingActionItem(title: NSLocalizedString("Navigate", comment: "Product action: Navigate"),
                    image: "productNavigate", action: .Navigate),
                TrainingActionItem(title: NSLocalizedString("More Information", comment: "Product action: More Information"), image: "productTerms&Info", action: .ProductInventory),
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

extension TrainingDetailsViewController {
    enum TrainingDetailsAction: CustomStringConvertible {
        case Buy, ProductInventory, SellerProfile, SendMessage, Navigate
        
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
            case .Navigate:
                return "Navigate"
            }
        }
    }
    
    
    struct TrainingActionItem {
        let title: String
        let image: String
        let action: TrainingDetailsAction
    }
}

extension TrainingDetailsViewController {
    internal class TrainingDetailsDataSource: TableViewDataSource {
        
        var items: [[TrainingActionItem]] = []
        
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
    }
}

