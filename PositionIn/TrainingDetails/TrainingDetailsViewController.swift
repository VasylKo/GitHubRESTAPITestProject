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

protocol TrainingDetailsActionConsumer {
    func executeAction(action: TrainingDetailsViewController.TrainingDetailsAction)
}

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
        
        let image = UIImage(named: "trainings_placeholder")
        
        productImageView.setImageFromURL(product.imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            self.pinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
                self?.dataSource.items = (self?.trainingActionItems())!
                self?.dataSource.configureTable((self?.actionTableView)!)
                }.onFailure(callback: { (error:NSError) -> Void in
                    self.pinDistanceImageView.hidden = true
                    self.infoLabel.text = "" })
        } else {
            self.pinDistanceImageView.hidden = true
            self.infoLabel.text = ""
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
        let zeroSection = [ // 0 section
            TrainingActionItem(title: NSLocalizedString("Sign Up", comment: "Product action: Buy Product"),
                image: "productBuyProduct",
                action: .Buy)]
        
        var firstSection = [ // 1 section
            TrainingActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"),
                image: "productSendMessage", action: .SendMessage),
            TrainingActionItem(title: NSLocalizedString("Organizer Profile", comment: "Product action: Seller Profile"),
                image: "productSellerProfile", action: .SellerProfile),
            /*TrainingActionItem(title: NSLocalizedString("More Information", comment: "Product action: More Information"), image: "productTerms&Info", action: .ProductInventory),*/
        ]
        if self.product?.location != nil {
            firstSection.append(TrainingActionItem(title: NSLocalizedString("Navigate", comment: "Product action: Navigate"), image: "productNavigate", action: .Navigate))
        }
        
        return [zeroSection, firstSection]
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak var pinDistanceImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension TrainingDetailsViewController : TrainingDetailsActionConsumer {
    
    enum TrainingDetailsAction: CustomStringConvertible {
        case Buy, ProductInventory, SendMessage, SellerProfile, Navigate
        
        var description: String {
            switch self {
            case .Buy:
                return "Buy"
            case .ProductInventory:
                return "Product Inventory"
            case .SendMessage:
                return "Send message"
            case .SellerProfile:
                return "Seller profile"
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
    
    func executeAction(action: TrainingDetailsAction) {
        let segue: TrainingDetailsViewController.Segue
        switch action {
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Navigate:
            if let coordinates = self.product?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        case .SellerProfile:
            segue = .showUserProfile
        default:
            return
        }
        performSegue(segue)
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
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = items[indexPath.section][indexPath.row]
            if let actionConsumer = parentViewController as? TrainingDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}

