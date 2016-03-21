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

    var price: NSNumber? {
        didSet {
            if let price = price {
                self.totalLabel.text = String(price)
            }
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            self.iconImageView.setImageFromURL(imageURL, placeholder: nil)
        }
    }
    
    var quantity: NSNumber? {
        didSet {
            if let quantity = price {
                self.self.quintityLabel.text = String(quantity)
            }
        }
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
    }

    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 350
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var pickUpAvailabilityLabel: UILabel!
    @IBOutlet private weak var quintityLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
}
