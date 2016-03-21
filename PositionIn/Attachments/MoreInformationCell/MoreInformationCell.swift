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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionImageView: UIImageView!
    
    
    var attachment: Attachment? {
        let box = self.rowDescriptor?.value as? Box<Attachment>
        return box?.value
    }
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
        
        self.titleLabel.text = self.attachment?.name ?? ""
        if let name = self.attachment?.name {
            let components = name.componentsSeparatedByString(".")
            if components.count > 1 {
                self.descriptionLabel.text = components.last?.uppercaseString
                self.titleLabel.text = components[components.count - 2]
            } else {
                self.titleLabel.text = components.last
            }
        }
        
        let placeholder : UIImage
        if self.attachment?.type?.containsString("pdf") == true {
            placeholder = UIImage(named: "ic_pdf_attachment")!
        } else {
            placeholder = UIImage(named: "ic_image_attachment")!
        }
        
        self.descriptionImageView?.image = placeholder
        if let url = self.attachment?.url {
            self.descriptionImageView.setImageFromURL(url)
        }
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 65
    }
}
