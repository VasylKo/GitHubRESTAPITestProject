//
//  OrderQuantityViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 20/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeQuantityViewCell = "XLFormRowDescriptorTypeQuantityViewCell"

class OrderQuantityViewCell: XLFormBaseCell {
    //MARK - Internal
    internal var quantity: Int {
        get {
           return Int(quantityStepper?.value ?? 0)
        }
    }
    
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 120
    }
    
    //MARK - Private
    
    //MARK - Private outlets
    @IBOutlet private weak var quantityStepper: UIStepper?
    @IBOutlet private weak var quantityLabel: UILabel?
    @IBOutlet private weak var totalLabel: UILabel?
    
}


