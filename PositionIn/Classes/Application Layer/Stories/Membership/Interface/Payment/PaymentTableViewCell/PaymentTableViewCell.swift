//
//  PaymentTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 07/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypePayment = "XLFormRowDescriptorTypePayment"

class PaymentTableViewCell: XLFormBaseCell {
    
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
    
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var planName: UILabel!
    @IBOutlet private weak var planImageView: UIImageView!
}
