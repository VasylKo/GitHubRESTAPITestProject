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
        
        if self.attachment?.type?.containsString("/") == true {
            let description = self.attachment?.type?.componentsSeparatedByString("/").last?.uppercaseString
            self.descriptionLabel.text = description
        } else {
            self.descriptionLabel.text = self.attachment?.type ?? ""
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
