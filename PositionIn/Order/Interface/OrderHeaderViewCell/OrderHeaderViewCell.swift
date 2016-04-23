//
//  OrderHeaderViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 20/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeOrderHeder = "XLFormRowDescriptorTypeOrderHeder"

class OrderHeaderViewCell: XLFormBaseCell {

    var name: String? {
        didSet {
            self.productNameLabel?.text = name
        }
    }
    
    var projectIconURL: NSURL? {
        didSet {
            self.productIconImageView?.setImageFromURL(projectIconURL, placeholder: nil)
        }
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 80
    }
    
    @IBOutlet private weak var productIconImageView: UIImageView?
    @IBOutlet private weak var productNameLabel: UILabel?
}
