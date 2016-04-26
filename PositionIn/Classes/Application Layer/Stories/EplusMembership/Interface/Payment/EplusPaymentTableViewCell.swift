//
//  EplusPaymentTableViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeAmbulancePayment = "XLFormRowDescriptorTypeAmbulancePayment"

class EplusPaymentTableViewCell: XLFormBaseCell {
    
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
        return EplusPaymentTableViewCell.cellHeight
    }
    
    static let cellHeight = CGFloat(122.0)
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var planName: UILabel!
    @IBOutlet weak var planImageView: UIImageView!
}
