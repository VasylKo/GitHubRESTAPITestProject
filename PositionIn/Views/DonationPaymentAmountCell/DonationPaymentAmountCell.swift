//
//  DonationPaymentAmountCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 11/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeDonationPaymentAmountCell = "XLFormRowDescriptorTypeDonationPaymentAmountCell"

class DonationPaymentAmountCell: XLFormBaseCell {

    var textToShow: String? {
        didSet {
            if let text = textToShow {
                self.warningTextLabel.text = text
            }
            
        }
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
    }

    
    @IBOutlet private weak var warningTextLabel: UILabel!
}
