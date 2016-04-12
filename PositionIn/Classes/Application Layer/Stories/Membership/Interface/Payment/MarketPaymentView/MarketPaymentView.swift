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
                self.totalLabel?.text = AppConfiguration().currencyFormatter.stringFromNumber(totalPrice)
            }
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            let defaultImage = UIImage(named: "market_img_default")
            self.iconImageView?.setImageFromURL(imageURL, placeholder: defaultImage)
        }
    }
    
    var quantity: NSNumber? {
        didSet {
            if let quantity = quantity {
                self.quintityLabel?.text = String(quantity)
            }
        }
    }
    
    var itemName: String? {
        didSet {
            self.itemNameLabel?.text = itemName ?? ""
        }
    }
    
    var pickUpAvailability: String? {
        didSet {
            if let text = pickUpAvailability {
                MarketPaymentView.pickUpAvaiabililityCellHeight = 61
                self.pickUpAvaiabililityCellHeightConstraint?.constant = MarketPaymentView.pickUpAvaiabililityCellHeight
                self.pickUpAvailabilityLabel?.text = text
                self.update()
            }
        }
    }

    override func configure() {
        super.configure()
        //Hide pickUpAvailabilityLabel
        MarketPaymentView.pickUpAvaiabililityCellHeight = 0
        self.pickUpAvaiabililityCellHeightConstraint?.constant = MarketPaymentView.pickUpAvaiabililityCellHeight
    }
    
    override func update() {
        super.update()
    }

    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 175 + MarketPaymentView.pickUpAvaiabililityCellHeight
    }
    
    @IBOutlet private weak var iconImageView: UIImageView?
    @IBOutlet private weak var itemNameLabel: UILabel?
    @IBOutlet private weak var pickUpAvailabilityLabel: UILabel?
    @IBOutlet private weak var quintityLabel: UILabel?
    @IBOutlet private weak var totalLabel: UILabel?
    @IBOutlet private weak var pickUpAvaiabililityCellHeightConstraint: NSLayoutConstraint?
    
    static var pickUpAvaiabililityCellHeight: CGFloat = 0

}
