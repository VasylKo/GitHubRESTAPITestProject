//
//  MPesaBongaPinView.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 08/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

let XLFormRowDescriptorTypeMPesaBongaPinView = "XLFormRowDescriptorTypeMPesaBongaPinView"

class MPesaBongaPinView: XLFormBaseCell {
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 102
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
        
    }
        
    @IBAction func moreButtonPressed(sender: UIButton) {
        guard let mpesaURL = NSURL(string: "http://www.safaricom.co.ke/personal/m-pesa") else { return }
        OpenApplication.Safari(with: mpesaURL)
    }
    
    @IBAction func dialNumberButtonPressed(sender: UIButton) {
        OpenApplication.Tel(with: "*126*5#")
    }
}
