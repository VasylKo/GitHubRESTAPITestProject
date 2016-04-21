//
//  AvailabilityViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 21/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeAvailabilityViewCell = "XLFormRowDescriptorTypeAvailabilityViewCell"

class AvailabilityViewCell: XLFormBaseCell {
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 50
    }
}
