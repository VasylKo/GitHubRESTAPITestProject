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
        title = NSLocalizedString("Project", comment: "Project details: title")
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
                return api().getProjectsDetails(objectId)
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
        
        let image = UIImage(named: "hardware_img_default")

        productImageView.setImageFromURL(imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            self.pinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
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
    
    private lazy var dataSource: ProductDetailsDataSource = { [unowned self] in
        let dataSource = ProductDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[ProductActionItem]] {
        let zeroSection = [ // 0 section
            ProductActionItem(title: NSLocalizedString("Donate", comment: "Product action: Buy Product"),
                image: "home_donate",
                action: .Buy)]
        
        var firstSection = [ // 1 section
            ProductActionItem(title: NSLocalizedString("Send Message", comment: "Product action: Send Message"), image: "productSendMessage", action: .SendMessage),
            ProductActionItem(title: NSLocalizedString("Organizer Profile", comment: "Product action: Seller Profile"), image: "productSellerProfile", action: .SellerProfile)]
        if self.product?.location != nil {
            firstSection.append(ProductActionItem(title: NSLocalizedString("Navigate", comment: "Product action: Navigate"), image: "productNavigate", action: .Navigate))
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

extension ProductDetailsViewController {
    enum ProductDetailsAction: CustomStringConvertible {
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
            if api().isUserAuthorized() {
                return
            } else {
                api().logout().onComplete {[weak self] _ in
                    self?.sideBarController?.executeAction(.Login)
                }
                return
            }
        case .ProductInventory:
            segue = .ShowProductInventory
        case .Navigate:
            if let coordinates = self.product?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        case .SellerProfile:
            segue = .ShowSellerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
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
        let imageName: String
        switch self {
        case .AnimalsPetSupplies:
            imageName = "animals_pet_supplies_img_default"
        case .ApparelAccessories:
            imageName = "apparel_accessories_img_default"
        case .ArtsEntertainment:
            imageName = "arts_entertainment_img_default"
        case .BabyToddler:
            imageName = "baby_toddler_img_default"
        case .BusinessIndustrial:
            imageName = "business_industrial_img_default"
        case .CamerasOptics:
            imageName = "cameras_optics_img_default"
        case .Electronics:
            imageName = "electronics_img_default"
        case .Food:
            imageName = "food_img_default"
        case .Furniture:
            imageName = "furniture_img_default"
        case .Hardware:
            imageName = "hardware_img_default"
        case .HealthBeauty:
            imageName = "health_beauty_img_default"
        case .HomeGarden:
            imageName = "home_garden_img_default"
        case .LuggageBags:
            imageName = "luggage_bags_img_default"
        case .Unknown:
            fallthrough
        default:
            imageName = ""
        }
        return UIImage(named: imageName) ?? UIImage()
    }
}