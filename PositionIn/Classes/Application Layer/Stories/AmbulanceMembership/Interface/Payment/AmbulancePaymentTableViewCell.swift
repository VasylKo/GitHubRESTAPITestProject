//
//  AmbulancePaymentTableViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeAmbulancePayment = "XLFormRowDescriptorTypeAmbulancePayment"

class AmbulancePaymentTableViewCell: XLFormBaseCell {
    
    var totalString: String? {
        didSet{
            self.totalLabel.text = totalString
        }
    }
    
    var planString: String? {
        didSet{
            self.planName.text = planString
        }
    }
    
    var planImage: UIImage? {
        didSet{
            self.planImageView.image = planImage
        }
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 122
    }
    
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var planName: UILabel!
    @IBOutlet private weak var planImageView: UIImageView!
}
