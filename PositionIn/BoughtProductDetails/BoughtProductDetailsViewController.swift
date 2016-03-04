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
        
//        if self.author?.objectId != api().currentUserId() {
//            firstSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"),
//                image: "productSendMessage", action: .SendMessage))
//            
//            firstSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("Organizer Profile", comment: "Product action: Seller Profile"),
//                image: "productSellerProfile", action: .SellerProfile))
//        }
//        
        if product?.entityDetails?.location != nil {
            zeroSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("Navigate", comment: "Product action: Navigate"), image: "productNavigate", action: .Navigate))
        }

        if product?.entityDetails?.links?.isEmpty == false || product?.entityDetails?.attachments?.isEmpty == false {
            zeroSection.append(BoughtProductDetailsActionItem(title: NSLocalizedString("More Information", comment: "Product action: More Information"), image: "productTerms&Info", action: .MoreInformation))
        }
        
        return [zeroSection]
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Purchases")
        dataSource.items = productActionItems()
        if let actionTableView = actionTableView {
            dataSource.configureTable(actionTableView)
        }
        reloadData()
    }
    
    // MARK: - Private functions
    private func reloadData() {
        actionTableView?.reloadData()
    }
}

// MARK: - BoughtProductDetailsActionConsumer
extension BoughtProductDetailsViewController: BoughtProductDetailsActionConsumer {
    enum BoughtProductDetailsAction: CustomStringConvertible {
        case Buy, ProductInventory, SendMessage, SellerProfile, Navigate, MoreInformation
        
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
        //let segue: TrainingDetailsViewController.Segue
        switch action {
        case .Buy:
//            if let urlString = self.product?.externalURLString {
//                let url = NSURL(string: urlString)
//                if let url = url {
//                    OpenApplication.Safari(with: url)
//                }
//            }
            return
        case .SendMessage:
//            if let userId = author?.objectId {
//                showChatViewController(userId)
//            }
            return
        case .Navigate:
//            if let coordinates = self.product?.location?.coordinates {
//                OpenApplication.appleMap(with: coordinates)
//            } else {
//                Log.error?.message("coordinates missed")
//            }
            return
        case .SellerProfile:
            return
            //segue = .showUserProfile
        case .MoreInformation:
//            if self.product?.links?.isEmpty == false || self.product?.attachments?.isEmpty == false {
//                let moreInformationViewController = MoreInformationViewController(links: self.product?.links, attachments: self.product?.attachments)
//                self.navigationController?.pushViewController(moreInformationViewController, animated: true)
//            }
            return
        default:
            return
        }
        //performSegue(segue)
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
        
//        @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            if section == 1 {
//                return 50
//            }
//            return super.tableView(tableView, heightForHeaderInSection: section)
//        }
//        
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