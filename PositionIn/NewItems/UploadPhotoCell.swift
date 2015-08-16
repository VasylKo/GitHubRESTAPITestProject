//
//  UploadPhotoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Photos

let XLFormRowDescriptorTypeUploadPhoto = "XLFormRowDescriptorTypeUploadPhoto"

class UploadPhotoCell: XLFormBaseCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func configure() {
        super.configure()
        self.selectionStyle = .None
        self.textLabel!.textColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        self.textLabel!.textAlignment = .Center
    }
    
    override func update() {
        super.update()
        imagePreviews.map { preview in
            preview.removeFromSuperview()
        }
        if let assets = self.assets {
            self.textLabel!.text = "Assets: \(count(assets))"
        } else {
            self.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            self.textLabel!.text = NSLocalizedString("Insert photo", comment: "New item: insert photo")
        }
    }
    
    
    override func formDescriptorCellDidSelectedWithFormController(controller: XLFormViewController!) {
        self.rowDescriptor.value = nil
        if let addItemController = controller as? BaseAddItemViewController {
            addItemController.didTouchPhoto(self.rowDescriptor)
        }
        self.update()
        controller.tableView .selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    var assets: [PHAsset]? {
        return self.rowDescriptor.value as? [PHAsset]
    }
    
    private var imagePreviews: [UIImageView] = []
    
}
