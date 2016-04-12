//
//  BoughtProductDetailsViewController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 03/03/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

protocol BoughtProductDetailsActionConsumer {
    func executeAction(action: BoughtProductDetailsViewController.BoughtProductDetailsAction)
}

final class BoughtProductDetailsViewController: UIViewController {
    // MARK: - IBOutles
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var productNameLabel: UILabel?
    @IBOutlet weak var orderStatusLabel: UILabel?
    @IBOutlet weak var pickUpAvailabilityLabel: UILabel?
    @IBOutlet weak var quantityLabel: UILabel?
    @IBOutlet weak var paymentMethodLabel: UILabel?
    @IBOutlet weak var paymentDateLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var transactionIDLabel: UILabel?
    
    @IBOutlet weak var pickUpAvaiabililityCellHeightConstraints: NSLayoutConstraint?
    
    @IBOutlet weak var actionTableView: UITableView?
    
    // MARK: - Internal properties
    internal var product: Order?
    
    // MARK: - Private properties
    private lazy var dataSource: BoughtProductDetailsDataSource = { [unowned self] in
        let dataSource = BoughtProductDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
    }()
    
    private func productActionItems() -> [[BoughtProductDetailsActionItem]] {
        var zeroSection = [BoughtProductDetailsActionItem]() // 1 section
        
        if product?.entityDetails?.author?.objectId != api().currentUserId() {
            zeroSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"),
                image: "productSendMessage", action: .SendMessage))
            
            zeroSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("Seller Profile", comment: "Product action: Seller Profile"),
                image: "productSellerProfile", action: .SellerProfile))
        }

        if product?.entityDetails?.links?.isEmpty == false || product?.entityDetails?.attachments?.isEmpty == false {
            zeroSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("More Information", comment: "Product action: More Information"), image: "productTerms&Info", action: .MoreInformation))
        }
        
        return [zeroSection]
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.walletDetails)
    }
    
    // MARK: - UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileController = segue.destinationViewController  as? UserProfileViewController,
            let userId = product?.entityDetails?.author?.objectId {
                profileController.objectId = userId
        }
    }
    
    // MARK: - Private functions
    private func reloadData() {
        actionTableView?.reloadData()
    }
    
    private func configure() {
        title = NSLocalizedString("Purchases")
        
        productImage?.setImageFromURL(product?.entityDetails?.imageURL, placeholder: UIImage(named: "market_img_default"))
        productNameLabel?.text = product?.entityDetails?.name
        orderStatusLabel?.text = product?.status?.description
        //Hide pick-up avaiabilility cell if the product don't have one
        if let endData =  product?.entityDetails?.endData {
            pickUpAvailabilityLabel?.text = endData.formattedAsTimeAgo()
        } else {
            pickUpAvaiabililityCellHeightConstraints?.constant = 0
        }
        quantityLabel?.text = "\(product?.quantity ?? 0)"
        paymentMethodLabel?.text = product?.paymentMethod?.description
        transactionIDLabel?.text = product?.transactionId
        paymentDateLabel?.text = product?.paymentDate?.formattedAsTimeAgo()
        totalLabel?.text = AppConfiguration().currencyFormatter.stringFromNumber(product?.price ?? 0.0) ?? ""
        
        dataSource.items = productActionItems()
        if let actionTableView = actionTableView {
            dataSource.configureTable(actionTableView)
        }
    }
}

// MARK: - BoughtProductDetailsActionConsumer
extension BoughtProductDetailsViewController: BoughtProductDetailsActionConsumer {
    enum BoughtProductDetailsAction: CustomStringConvertible {
        case SendMessage, SellerProfile, MoreInformation
        
        var description: String {
            switch self {
            case .SendMessage:
                return "Send message"
            case .SellerProfile:
                return "Seller profile"
            case .MoreInformation:
                return "MoreInformation"
            }
        }
    }
    
    struct BoughtProductDetailsActionItem {
        let title: String
        let image: String
        let action: BoughtProductDetailsAction
    }
    
    func executeAction(action: BoughtProductDetailsAction) {
        let segue: BoughtProductDetailsViewController.Segue
        switch action {
        case .SendMessage:
            if let userId = product?.entityDetails?.author?.objectId {
                showChatViewController(userId)
            }
            return
        case .SellerProfile:
            segue = .ShowSellerProfile
        case .MoreInformation:
            if product?.entityDetails?.links?.isEmpty == false || product?.entityDetails?.attachments?.isEmpty == false {
                let moreInformationViewController = MoreInformationViewController(links: product?.entityDetails?.links, attachments: product?.entityDetails?.attachments)
                navigationController?.pushViewController(moreInformationViewController, animated: true)
            }
            return
        }
        performSegue(segue)
    }
}

// MARK: - BoughtProductDetailsViewController
extension BoughtProductDetailsViewController {
    internal class BoughtProductDetailsDataSource: TableViewDataSource {
        var items: [[BoughtProductDetailsActionItem]] = []
        
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
     
        override func nibCellsId() -> [String] {
            return [ActionCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = items[indexPath.section][indexPath.row]
            if let actionConsumer = parentViewController as? BoughtProductDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}