//
//  MarketPaymentView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 08/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MarketPaymentView: UIView {

    var product: Product? {
        didSet {
            if let product = self.product {
                self.iconImageView.setImageFromURL(product.imageURL, placeholder: nil)
                self.itemNameLabel.text = product.name
                //TODO: should set pickUpAvailabilityLabel 
                if let price = product.price {
                    self.subtotalLabel.text = String(price)
                    self.totalLabel.text = String(price)
                }
            }
        }
    }
    var quantity: Int? {
        didSet {
            if let quantity = self.quantity {
                self.quintityLabel.text = String(quantity)
            }
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var pickUpAvailabilityLabel: UILabel!
    @IBOutlet private weak var quintityLabel: UILabel!
    @IBOutlet private weak var subtotalLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    
//MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
