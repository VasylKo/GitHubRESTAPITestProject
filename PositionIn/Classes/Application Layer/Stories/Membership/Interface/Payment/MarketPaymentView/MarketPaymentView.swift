//
//  MarketPaymentView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 08/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeMarketPaymentView = "XLFormRowDescriptorTypeMarketPaymentView"

class MarketPaymentView: XLFormBaseCell {

    var totalPrice: NSNumber? {
        didSet {
            if let totalPrice = totalPrice {
                self.totalLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(totalPrice)
            }
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            let defaultImage = UIImage(named: "market_img_default")
            self.iconImageView.setImageFromURL(imageURL, placeholder: defaultImage)
        }
    }
    
    var quantity: NSNumber? {
        didSet {
            if let quantity = quantity {
                self.self.quintityLabel.text = String(quantity)
            }
        }
    }
    
    var itemName: String? {
        didSet {
            self.itemNameLabel.text = itemName ?? ""
        }
    }
    
    var pickUpAvailability: String? {
        didSet {
            self.pickUpAvailabilityLabel.text = pickUpAvailability
        }
    }

    override func configure() {
        super.configure()
        //pickUpAvailabilityLabel will be sat from product
        pickUpAvailabilityLabel.text = " "
    }
    
    override func update() {
        super.update()
    }

    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 236
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var pickUpAvailabilityLabel: UILabel!
    @IBOutlet private weak var quintityLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
}
