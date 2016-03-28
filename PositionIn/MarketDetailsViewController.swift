//
//  MarketDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol MarketDetailsActionConsumer {
        func executeAction(action: MarketDetailsViewController.MarketDetailsAction)
}

final class MarketDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Market", comment: "Market")
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
                return api().getMarketDetails(objectId)
                }.onSuccess { [weak self] product in
                    if let strongSelf = self {
                        strongSelf.didReceiveProductDetails(product)
                        strongSelf.dataSource.items = strongSelf.productAcionItems()
                        strongSelf.dataSource.configureTable(strongSelf.actionTableView)
                    }
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveProductDetails(product: Product) {
        self.product = product
        headerLabel.text = product.name
        detailsLabel.text = product.text?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        
        nameLabel.text = author?.title
        
        priceLabel.text = product.price.map {
            let newValue = $0 as Float
            return AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""}
        
        let image = UIImage(named: "market_img_default")
        
        productImageView.setImageFromURL(product.imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            self.pinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceStringFromCoordinate(coordinates).onSuccess() {
                [weak self] distanceString in
                self?.infoLabel.text = distanceString
                self?.dataSource.items = (self?.productAcionItems())!
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
    
    private lazy var dataSource: MarketDetailsDataSource = { [unowned self] in
        let dataSource = MarketDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[MarketActionItem]] {
        let zeroSection = [ // 0 section
            MarketActionItem(title: NSLocalizedString("Buy Product", comment: "Buy: Market"),
                image: "productBuyProduct",
                action: .Buy)]
        var firstSection = [MarketActionItem]() // 1 section
        
        if self.author?.objectId != api().currentUserId() {
            firstSection.append(MarketActionItem(title: NSLocalizedString("Send Message", comment: "Market"), image: "productSendMessage", action: .SendMessage))
            firstSection.append(MarketActionItem(title: NSLocalizedString("Seller Profile", comment: "Market"),
                image: "productSellerProfile", action: .SellerProfile))
        }
        
        if self.product?.location != nil {
            firstSection.append(MarketActionItem(title: NSLocalizedString("Navigate", comment: "Market"), image: "productNavigate", action: .Navigate))
        }
        if self.product?.links?.isEmpty == false || self.product?.attachments?.isEmpty == false {
            firstSection.append(MarketActionItem(title: NSLocalizedString("More Information"), image: "productTerms&Info", action: .MoreInformation))
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

extension MarketDetailsViewController {
    enum MarketDetailsAction: CustomStringConvertible {
        case Buy, SellerProfile, SendMessage, Navigate, MoreInformation
        
        var description: String {
            switch self {
            case .Buy:
                return "Buy"
            case .SellerProfile:
                return "Seller profile"
            case .SendMessage:
                return "Send message"
            case .Navigate:
                return "Navigate"
            case .MoreInformation:
                return "More Information"
            }
        }
    }
    
    
    struct MarketActionItem {
        let title: String
        let image: String
        let action: MarketDetailsAction
    }
}

extension MarketDetailsViewController: MarketDetailsActionConsumer {
    func executeAction(action: MarketDetailsAction) {
        let segue: MarketDetailsViewController.Segue
        switch action {
        case .Buy:
            segue = .ShowBuyScreen
        case .SellerProfile:
            segue = .ShowOrganizerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .MoreInformation:
            if self.product?.links?.isEmpty == false || self.product?.attachments?.isEmpty == false {
                let moreInformationViewController = MoreInformationViewController(links: self.product?.links, attachments: self.product?.attachments)
                self.navigationController?.pushViewController(moreInformationViewController, animated: true)
            }
            return
        case .Navigate:
            if let coordinates = self.product?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        }
        performSegue(segue)
    }
}

extension MarketDetailsViewController {
    internal class MarketDetailsDataSource: TableViewDataSource {
        
        var items: [[MarketActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? MarketDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}
