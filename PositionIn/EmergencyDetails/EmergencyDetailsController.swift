//
//  EmergencyDetailsController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 04/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol EmergencyDetailsActionConsumer {
    func executeAction(action: EmergencyDetailsController.EmergencyDetailsAction)
}

class EmergencyDetailsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Emergency Alerts", comment: "Product details: title")
        dataSource.items = productAcionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.emergencyAlertDetails)
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
                return api().getEmergencyDetails(objectId)
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
        if let name = self.author?.title {
            nameLabel.text = name
        }
        
        let image = UIImage(named: "PromotionDetailsPlaceholder")
        
        productImageView.setImageFromURL(product.imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            self.pinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceStringFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
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
    
    private lazy var dataSource: EmergencyDetailsDataSource = { [unowned self] in
        let dataSource = EmergencyDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[EmergencyActionItem]] {
        let zeroSection = [ // 0 section
            EmergencyActionItem(title: NSLocalizedString("Donate", comment: "Product action: Buy Product"),
                image: "home_donate",
                action: .Donate)]

        var firstSection = [EmergencyActionItem]() // 1 section
        
        if self.author?.objectId != api().currentUserId() {
            firstSection.append(EmergencyActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"),
                image: "productSendMessage",
                action: .SendMessage))
            firstSection.append(EmergencyActionItem(title: NSLocalizedString("Member Profile",
                comment: "Product action: Seller Profile"), image: "productSellerProfile", action: .MemberProfile))
        }
        
        
        
        if self.product?.location != nil {
            firstSection.append(EmergencyActionItem(title: NSLocalizedString("Navigate", comment: "Emergency"), image: "productNavigate", action: .Navigate))
        }
        if self.product?.links?.isEmpty == false || self.product?.attachments?.isEmpty == false {
            firstSection.append(EmergencyActionItem(title: NSLocalizedString("Attachments"), image: "productTerms&Info", action: .MoreInformation))
        }
        
        return [zeroSection, firstSection]
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak var pinDistanceImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension EmergencyDetailsController {
    enum EmergencyDetailsAction: CustomStringConvertible {
        case Donate, Navigate, SendMessage, MemberProfile, MoreInformation
        
        var description: String {
            switch self {
            case .Donate:
                return "Donate"
            case .Navigate:
                return "Navigate"
            case .SendMessage:
                return "Send Message"
            case .MemberProfile:
                return "Member Profile"
            case .MoreInformation:
                return "More Information"
            }
        }
    }
    
    
    struct EmergencyActionItem {
        let title: String
        let image: String
        let action: EmergencyDetailsAction
    }
}

extension EmergencyDetailsController: EmergencyDetailsActionConsumer {
    
    func executeAction(action: EmergencyDetailsAction) {
        let segue: EmergencyDetailsController.Segue
        switch action {
        case .Navigate:
            if let coordinates = self.product?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        case .Donate:
            let donateController = Storyboards.Onboarding.instantiateDonateViewController()
            donateController.product = self.product
            donateController.viewControllerToOpenOnComplete = self
            donateController.donationType = .EmergencyAlert
            trackEventToAnalytics(AnalyticCategories.labelForDonationType(donateController.donationType), action: AnalyticActios.donate, label: product?.name ?? NSLocalizedString("Can't get product type"))
            self.navigationController?.pushViewController(donateController, animated: true)
            return
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .MemberProfile:
            segue = .ShowSellerProfile
        case .MoreInformation:
            if self.product?.links?.isEmpty == false || self.product?.attachments?.isEmpty == false {
                let moreInformationViewController = MoreInformationViewController(links: self.product?.links, attachments: self.product?.attachments)
                self.navigationController?.pushViewController(moreInformationViewController, animated: true)
            }
            return
        }
        performSegue(segue)
    }
}

extension EmergencyDetailsController {
    internal class EmergencyDetailsDataSource: TableViewDataSource {
        
        var items: [[EmergencyActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? EmergencyDetailsController {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}