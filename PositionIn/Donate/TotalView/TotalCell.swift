//
//  TotalCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeTotal = "XLFormRowDescriptorTypeTotal"

class TotalCell: XLFormBaseCell {

    var price: String? {
        didSet {
            self.priceLabel.text = price
        }
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 50.0
    }
    
    @IBOutlet weak var priceLabel: UILabel!
}
