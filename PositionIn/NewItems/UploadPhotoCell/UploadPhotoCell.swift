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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func configure() {
        super.configure()
        self.selectionStyle = .None
        let invitationView = PickPhotoView(frame: CGRectZero)
        self.invitationView = invitationView
        contentView.addSubViewOnEntireSize(invitationView)
        let previewView = AttachedPhotosView(frame: CGRectZero)
        assetsPreviewView = previewView
        contentView.addSubViewOnEntireSize(previewView)
    }
    
    override func update() {
        super.update()
        if let asset = assets?.first {
            assetsPreviewView.hidden = false
            invitationView.hidden = true
            assetsPreviewView.assetImageView.image = UIImage(named: "compactPlaceholder")
            assetsPreviewView.layoutIfNeeded()
            let previewSize = assetsPreviewView.bounds.size
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .FastFormat
            imageManager.requestImageForAsset(asset,
                targetSize: previewSize,
                contentMode: .AspectFit,
                options: requestOptions,
                resultHandler: {
                    [weak imageView = self.assetsPreviewView.assetImageView]
                    (image, info) -> Void in
                    imageView?.image = image
            })
        } else {
            assetsPreviewView.hidden = true
            invitationView.hidden = false
        }
    }
    
    override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 44
    }
    
    override func formDescriptorCellDidSelectedWithFormController(controller: XLFormViewController!) {
        self.rowDescriptor?.value = nil
        self.update()
        controller.tableView .selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.None)
        guard  let addItemController = controller as? BaseAddItemViewController,
               let descriptor = self.rowDescriptor else {
                return
        }
        addItemController.didTouchPhoto(descriptor)
    }
    
    var assets: [PHAsset]? {
        return self.rowDescriptor?.value as? [PHAsset]
    }
    
    private weak var invitationView: PickPhotoView!
    private weak var assetsPreviewView: AttachedPhotosView!
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
}
