//
//  BomaHotelsDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures
import MapKit

protocol BomaHotelsDetailsActionConsumer {
    func executeAction(action: BomaHotelsDetailsViewController.BomaHotelsDetailsAction)
}

final class BomaHotelsDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Boma Hotels",
            comment: "Project details: title")
        dataSource.items = bomaHotelAcionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// unsupported functionality?
//        if let orderController = segue.destinationViewController  as? OrderViewController {
//            orderController.product = product
//        }
        if let profileController = segue.destinationViewController  as? UserProfileViewController,
            let userId = author?.objectId {
                profileController.objectId = userId
        }
    }
    
    private func reloadData() {
        self.infoLabel.text = NSLocalizedString("Calculating...",
            comment: "Distance calculation process")
        switch (objectId, author) {
        case (.Some(let objectId), .Some(let author) ):
            api().getUserProfile(author.objectId).flatMap { (profile: UserProfile) -> Future<BomaHotel, NSError> in
                return api().getBomaHotelsDetails(objectId)
                }.onSuccess { [weak self] bomaHotel in
                    self?.didReceiveBomaHotelDetails(bomaHotel)
                    self?.dataSource.items = (self?.bomaHotelAcionItems())!
                    self?.dataSource.configureTable((self?.actionTableView)!)
            }
        default:
            Log.error?.message("Not enough data to load boma hotel")
        }
    }
    
    private func didReceiveBomaHotelDetails(bomaHotel: BomaHotel) {
        self.bomaHotel = bomaHotel
        headerLabel.text = bomaHotel.name
        detailsLabel.text = bomaHotel.text?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        if let price = bomaHotel.donations {
            priceLabel.text = "\(Int(price)) beneficiaries"
        }

        let imageURL: NSURL?
        
        if let urlString = bomaHotel.imageURLString {
            imageURL = NSURL(string:urlString)
        } else {
            imageURL = nil
        }
        
        let image = UIImage(named: "bomaHotelPlaceholder")
        productImageView.setImageFromURL(imageURL, placeholder: image)
        if let coordinates = bomaHotel.location?.coordinates {
            self.productPinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
                self?.dataSource.items = (self?.bomaHotelAcionItems())!
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
    
    private var bomaHotel: BomaHotel?
    private var locationRequestToken = InvalidationToken()
    
    private lazy var dataSource: BomaHotelsDetailsDataSource = { [unowned self] in
        let dataSource = BomaHotelsDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func bomaHotelAcionItems() -> [[BomaHotelActionItem]] {
        if self.bomaHotel?.bookingURL != nil {
            let zeroSection = [BomaHotelActionItem(title: NSLocalizedString("Booking", comment: "BomaHotels"), image: "productBuyProduct", action: .Buy)]
            var firstSection = [BomaHotelActionItem(title: NSLocalizedString("Send Message", comment: "BomaHotels"), image: "productSendMessage", action: .SendMessage),
                BomaHotelActionItem(title: NSLocalizedString("Organizer Profile", comment: "BomaHotels"), image: "productSellerProfile", action: .SellerProfile)]
            if self.bomaHotel?.location != nil {
                firstSection.append(BomaHotelActionItem(title: NSLocalizedString("Navigate", comment: "BomaHotels"), image: "productNavigate", action: .Navigate))
            }
            return [zeroSection, firstSection]
        } else {
            var zeroSection = [BomaHotelActionItem(title: NSLocalizedString("Send Message", comment: "BomaHotels"), image: "productSendMessage", action: .SendMessage),
                BomaHotelActionItem(title: NSLocalizedString("Organizer Profile", comment: "BomaHotels"), image: "productSellerProfile", action: .SellerProfile)]
            if self.bomaHotel?.location != nil {
                zeroSection.append(BomaHotelActionItem(title: NSLocalizedString("Navigate", comment: "BomaHotels"), image: "productNavigate", action: .Navigate))
            }
            return [zeroSection]
        }
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak var productPinDistanceImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension BomaHotelsDetailsViewController {
    enum BomaHotelsDetailsAction: CustomStringConvertible {
        case Buy, Navigate, ProductInventory, SellerProfile, SendMessage
        
        var description: String {
            switch self {
            case .Buy:
                return "Buy"
            case .Navigate:
                return "Navigate"
            case .ProductInventory:
                return "Product Inventory"
            case .SellerProfile:
                return "Seller profile"
            case .SendMessage:
                return "Send message"
            }
        }
    }
    
    struct BomaHotelActionItem {
        let title: String
        let image: String
        let action: BomaHotelsDetailsAction
    }
}

extension BomaHotelsDetailsViewController: BomaHotelsDetailsActionConsumer {
    func executeAction(action: BomaHotelsDetailsAction) {
        let segue: BomaHotelsDetailsViewController.Segue
        switch action {
        case .SellerProfile:
            segue = .ShowOrganizerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Buy:
            if let bookingURL = self.bomaHotel?.bookingURL {
                OpenApplication.Safari(with: bookingURL)
            }
            return
        case .Navigate:
            if let coordinates = self.bomaHotel?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        default:
            return
        }
        performSegue(segue)
    }
}

extension BomaHotelsDetailsViewController {
    internal class BomaHotelsDetailsDataSource: TableViewDataSource {
        
        var items: [[BomaHotelActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? BomaHotelsDetailsViewController {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}
