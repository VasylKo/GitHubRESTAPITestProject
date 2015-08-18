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
        imagePreviews = []
        if let assets = self.assets {
            self.textLabel!.text = "Assets: \(count(assets))"

            let previewWidth: CGFloat = bounds.width / CGFloat(count(assets))
            let previewHeight = bounds.height
            let previewSize = CGSize(width: previewWidth, height: previewHeight)
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .FastFormat
            enumerate(assets)
            for (index, asset) in enumerate(assets) {

                let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: previewWidth * CGFloat(index), y: 0), size: previewSize))
                self.contentView.addSubview(imageView)
                
                self.imageManager.requestImageForAsset(asset,
                    targetSize: previewSize,
                    contentMode: .AspectFill,
                    options: requestOptions,
                    resultHandler: { [weak imageView] (image, info) -> Void in
                        imageView?.image = image
                })
                imagePreviews.append(imageView)
            }
        } else {
            self.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            self.textLabel!.text = NSLocalizedString("Insert photo", comment: "New item: insert photo")
        }
    }
    
    
    override func formDescriptorCellDidSelectedWithFormController(controller: XLFormViewController!) {
        self.rowDescriptor.value = nil
        self.update()
        controller.tableView .selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.None)
        if let addItemController = controller as? BaseAddItemViewController {
            addItemController.didTouchPhoto(self.rowDescriptor)
        }
    }
    
    var assets: [PHAsset]? {
        return self.rowDescriptor.value as? [PHAsset]
    }
    
    private var imagePreviews: [UIImageView] = []
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
}
