//
//  TotalViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 21/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeTotalViewCell = "XLFormRowDescriptorTypeTotalViewCell"

class TotalViewCell: XLFormBaseCell {

    @IBOutlet private weak var priceLabel: UILabel?
    
    var priceText: String? {
        didSet {
            priceLabel?.text = priceText
        }
    }
    
   
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 50
    }
}
