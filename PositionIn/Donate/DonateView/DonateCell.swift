//
//  DonateView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeDonate = "XLFormRowDescriptorTypeDonate"

class DonateCell: XLFormBaseCell {

    var name: String? {
        didSet {
            self.projectNameLabel.text = name
        }
    }
    
    var projectIcon: UIImage? {
        didSet {
            self.projectIconImageView.image = projectIcon
        }
    }
    
    override func configure() {
        super.configure()
    }
    
    
    override func update() {
        super.update()
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 80
    }
    
    @IBOutlet private weak var projectIconImageView: UIImageView!
    @IBOutlet private weak var projectNameLabel: UILabel!
}
