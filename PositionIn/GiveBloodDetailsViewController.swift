//
//  GiveBloodDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol GiveBloodDetailsActionConsumer {
    func executeAction(action: GiveBloodDetailsViewController.GiveBloodDetailsAction)
}

class GiveBloodDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Give Blood", comment: "Give Blood details: title")
        dataSource.items = productAcionItems()
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
                return api().getGiveBloodDetails(objectId)
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
        if let price = product.donations {
            priceLabel.text = "\(Int(price)) beneficiaries"
        }
        
        let imageURL: NSURL?
        
        if let urlString = product.imageURLString {
            imageURL = NSURL(string:urlString)
        } else {
            imageURL = nil
        }
        
        let image = UIImage(named: "hardware_img_default")
        
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
    
    private lazy var dataSource: GiveBloodDetailsDataSource = { [unowned self] in
        let dataSource = GiveBloodDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[GiveBloodActionItem]] {
        return [
            [ // 0 section
                GiveBloodActionItem(title: NSLocalizedString("Navigate", comment: "GiveBlood"),
                    image: "productNavigate",
                    action: .Buy),
            ],
            [ // 1 section
                GiveBloodActionItem(title: NSLocalizedString("Send Message", comment: "GiveBlood"), image: "productSendMessage", action: .SendMessage),
                GiveBloodActionItem(title: NSLocalizedString("Office", comment: "GiveBlood"), image: "productSellerProfile", action: .ProductInventory),
                GiveBloodActionItem(title: NSLocalizedString("More Information", comment: "GiveBlood"), image: "productTerms&Info",
                    action: .ProductInventory),
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

extension GiveBloodDetailsViewController {
    enum GiveBloodDetailsAction: CustomStringConvertible {
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
    
    
    struct GiveBloodActionItem {
        let title: String
        let image: String
        let action: GiveBloodDetailsAction
    }
}

extension GiveBloodDetailsViewController: GiveBloodDetailsActionConsumer {
    func executeAction(action: GiveBloodDetailsAction) {
        let segue: GiveBloodDetailsViewController.Segue
        switch action {
        case .SellerProfile:
            segue = .ShowOrganizerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Buy:
            segue = .ShowOrganizerProfile
        case .ProductInventory:
            return
        }
        performSegue(segue)
    }
}

extension GiveBloodDetailsViewController {
    internal class GiveBloodDetailsDataSource: TableViewDataSource {
        
        var items: [[GiveBloodActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? GiveBloodDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}
