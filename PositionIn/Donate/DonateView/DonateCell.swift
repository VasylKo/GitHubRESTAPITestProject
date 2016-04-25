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
    
    var projectIconURL: NSURL? {
        didSet {
            self.projectIconImageView.setImageFromURL(projectIconURL, placeholder: nil)
        }
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return DonateCell.cellHeight
    }
    
    static let cellHeight = CGFloat(80.0)
    
    @IBOutlet weak var projectIconImageView: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
}
