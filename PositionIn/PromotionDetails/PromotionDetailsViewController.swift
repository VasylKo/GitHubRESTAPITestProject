//
//  PromotionDetailsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

protocol PromotionDetailsActionConsumer {
    func executeAction(action: PromotionDetailsViewController.PromotionDetailsAction)
}

final class PromotionDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Emergency", comment: "Promotion details: title")
        dataSource.items = promotionActionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    
    private func reloadData() {
        
    }
    
    private func didReceivePromotionDetails(product: Product) {
        self.product = product
        headerLabel.text = product.name
        detailsLabel.text = product.text
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
//        let startDate = dateFormatter.stringFromDate(product.startDate ?? NSDate())
//        let endDate = dateFormatter.stringFromDate(product.endDate ?? NSDate())
//        priceLabel.text = "\(startDate) - \(endDate)"
//        let discountFormat = NSLocalizedString("Save %.1f%%", comment: "Promotion details: DiscountFormat")
//        infoLabel.text = product.discount.map { String(format: discountFormat, $0 )}
        promotionImageView.setImageFromURL(product.photos?.first?.url, placeholder: UIImage(named: "PromotionDetailsPlaceholder"))
    }
    
    private lazy var dataSource: PromotionDetailsDataSource = { [unowned self] in
        let dataSource = PromotionDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func promotionActionItems() -> [[PromotionActionItem]] {
        return [
            [ // 0 section
                PromotionActionItem(title: NSLocalizedString("Products on Sale", comment: "Promotion action: Products on Sale"), image: "productBuyProduct", action: .ProductsOnSale),
            ],
            [ // 1 section
                PromotionActionItem(title: NSLocalizedString("Send Message", comment: "Promotion action: Send Message"), image: "productSendMessage", action: .SendMessage),
                PromotionActionItem(title: NSLocalizedString("Organize Profile", comment: "Promotion action: Seller Profile"), image: "productSellerProfile", action: .SellerProfile),
                PromotionActionItem(title: NSLocalizedString("Terms and Information", comment: "Promotion action: Terms and Information"), image: "productTerms&Info", action: .TermsAndInformation),
                PromotionActionItem(title: NSLocalizedString("More Information", comment: "Promotion action: Navigate"), image: "productNavigate", action: .Navigate)
            ],
        ]
    }
    
    
    var objectId: CRUDObjectId?
    private var product: Product?
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var promotionImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension PromotionDetailsViewController {
    enum PromotionDetailsAction: CustomStringConvertible {
        case  ProductsOnSale, SendMessage, SellerProfile, TermsAndInformation, Navigate
        
        var description: String {
            switch self {
            case .ProductsOnSale:
                return "Donate"
            case .SendMessage:
                return "Send Message"
            case .SellerProfile:
                return "Seller Profile"
            case .TermsAndInformation:
                return "Terms & Information"
            case .Navigate:
                return "Navigate"
            }
        }
    }
    
    
    struct PromotionActionItem {
        let title: String
        let image: String
        let action: PromotionDetailsAction
    }
    
    
}

extension PromotionDetailsViewController: PromotionDetailsActionConsumer {
    func executeAction(action: PromotionDetailsAction) {
        switch action {
//        case .SellerProfile:
//            if let userId = product?.author {
//                let profileController = Storyboards.Main.instantiateUserProfileViewController()
//                profileController.objectId = userId
//                navigationController?.pushViewController(profileController, animated: true)
//            }
//        case .SendMessage:
//            if let userId = product?.author {
//                showChatViewController(userId)
//            }

        default:
            Log.warning?.message("Unhandled action: \(action)")
            return
        }
    }
}

extension PromotionDetailsViewController {
    internal class PromotionDetailsDataSource: TableViewDataSource {
        
        var items: [[PromotionActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? PromotionDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
        
    }
}


