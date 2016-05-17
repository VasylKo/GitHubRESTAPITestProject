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
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        title = NSLocalizedString("Give Blood", comment: "Give Blood details: title")
        dataSource.items = productAcionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.giveBloodDetails)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let orderController = segue.destinationViewController  as? ProductOrderViewController {
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
                    if let strongSelf = self {
                        strongSelf.didReceiveProductDetails(product)
                        strongSelf.dataSource.items = strongSelf.productAcionItems()
                        strongSelf.dataSource.configureTable(strongSelf.actionTableView)
                        
                        //If there is only 1 attachment, thant show it on current screen
                        if let numberOfAttachments = strongSelf.product?.numberOfAttachments where numberOfAttachments == 1 {
                            strongSelf.actionTableViewHeightConstraint.constant = strongSelf.actionTableView.contentSize.height
                            strongSelf.addAttachmentSection()
                        } else {
                            //adjust scroll view content size based on table view height
                            let scrollViewBottomSpaceHeight: CGFloat = 20
                            strongSelf.actionTableViewHeightConstraint.constant = strongSelf.actionTableView.contentSize.height + scrollViewBottomSpaceHeight
                        }
                    }
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveProductDetails(product: Product) {
        self.product = product
        headerLabel.text = product.name
        nameLabel.text = author?.title
        detailsLabel.text = product.text?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        if let price = product.donations {
            nameLeadingConstraint?.priority = UILayoutPriorityDefaultLow
            priceLabel.text = "\(Int(price)) beneficiaries"
        } else {
            nameLeadingConstraint?.priority = UILayoutPriorityDefaultHigh
        }
        
        let image = UIImage(named: "give_blood_img_default")
        
        productImageView.setImageFromURL(product.imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            self.productPinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceStringFromCoordinate(coordinates).onSuccess() {
                [weak self] distanceString in
                self?.infoLabel.text = distanceString
                self?.dataSource.items = (self?.productAcionItems())!
                self?.dataSource.configureTable((self?.actionTableView)!)
                }.onFailure(callback: { (error:NSError) -> Void in
                    self.productPinDistanceImageView.hidden = true
                    self.infoLabel.text = "" })
        } else {
            self.productPinDistanceImageView.hidden = true
            self.infoLabel.text = ""
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
    
    
    private func addAttachmentSection() {
        attechmentSectionHeightConstraint.constant = MoreInformationViewController.singleAttacmentViewHeight
        let moreInformationViewController = MoreInformationViewController(links: self.product?.links, attachments: self.product?.attachments, bounces: false)
        let attachmentsView = moreInformationViewController.view
        attechmentSectionView.addSubview(attachmentsView)
    }
    
    private func productAcionItems() -> [[GiveBloodActionItem]] {
        var zeroSection = [GiveBloodActionItem]() // 0 section
        
        if self.author?.objectId != api().currentUserId() {
            zeroSection.append(GiveBloodActionItem(title: NSLocalizedString("Send Message", comment: "GiveBlood"), image: "productSendMessage", action: .SendMessage))   
            zeroSection.append(GiveBloodActionItem(title: NSLocalizedString("Office", comment: "GiveBlood"),
                image: "productSellerProfile", action: .ProductInventory))
        }
        
        if self.product?.location != nil {
            zeroSection.append(GiveBloodActionItem(title: NSLocalizedString("Navigate", comment: "GiveBlood"), image: "productNavigate", action: .Navigate))
        }
        if let numberOfAttachments = product?.numberOfAttachments where numberOfAttachments > 1 {
            zeroSection.append(GiveBloodActionItem(title: NSLocalizedString("Attachments"), image: "productTerms&Info", action: .MoreInformation))
        }
        
        return [zeroSection]
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet weak var actionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet weak var attechmentSectionView: UIView!
    @IBOutlet weak var attechmentSectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var productPinDistanceImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    @IBOutlet weak var nameLeadingConstraint: NSLayoutConstraint?
}

extension GiveBloodDetailsViewController {
    enum GiveBloodDetailsAction: CustomStringConvertible {
        case Buy, ProductInventory, SellerProfile, SendMessage, Navigate, MoreInformation
        
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
            case .MoreInformation:
                return "More Information"
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
            return
        case .Navigate:
            if let coordinates = self.product?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Buy:
            return
        case .ProductInventory:
            segue = .ShowOrganizerProfile
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
