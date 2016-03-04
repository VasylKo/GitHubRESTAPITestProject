//
//  MoreInformationCell.swift
//  PositionIn
//
//  Created by ng on 2/25/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm
import Box

let XLFormRowDescriptorTypeMoreInformation = "XLFormRowDescriptorTypeMoreInformation"

class MoreInformationCell : XLFormButtonCell {
    
    var attachment: Attachment? {
        let box = self.rowDescriptor?.value as? Box<Attachment>
        return box?.value
    }
    
    override func configure() {
        super.configure()
        
        self.textLabel?.textAlignment = .Left
        self.textLabel?.textColor = UIColor.blackColor()
        self.textLabel?.tintColor = UIScheme.mainThemeColor
    }
    
    override func update() {
        super.update()
        
        self.textLabel?.text = self.attachment?.name ?? ""
        
        let placeholder : UIImage
        if self.attachment?.type?.containsString("pdf") == true {
            placeholder = UIImage(named: "ic_pdf_attachment")!
        } else {
            placeholder = UIImage(named: "ic_image_attachment")!
        }
        
        self.imageView?.image = placeholder
        if let url = self.attachment?.url {
            self.imageView?.setImageFromURL(url)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)
    }
    
}
