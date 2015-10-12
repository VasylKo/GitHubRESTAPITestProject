//
//  SettingsHeaderCell.swift
//  PositionIn
//
//  Created by mpol on 10/8/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class SettingsHeaderCell: XLFormBaseCell {

    override func configure() {
        super.configure()
        self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
    
    
    class override func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 140
    }
    
    override func formDescriptorCellBecomeFirstResponder() -> Bool {
        return false
    }
}