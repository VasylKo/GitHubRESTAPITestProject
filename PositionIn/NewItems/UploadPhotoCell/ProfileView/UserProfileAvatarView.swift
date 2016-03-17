//
//  MembershipMemberProfileView.swift
//  PositionIn
//
//  Created by ng on 2/1/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Photos

protocol UserProfileAvatarViewDelegate {
    func addPhoto()
}

class UserProfileAvatarView : UIView {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var addPhotoLabel: UILabel!

    var asset : PHAsset?
    var delegate : UserProfileAvatarViewDelegate?
    
    override func awakeFromNib() {
        self.profileImageView.layer.masksToBounds = true
    }
    
    @IBAction func addPhotoAction(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.addPhoto()
        }
    }
    
    func setAvatar (url : NSURL) {
        self.profileImageView.setImageFromURL(url)
    }
    
    func configure (asset : PHAsset) {
        self.asset = asset
        let previewSize = profileImageView.bounds.size
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .FastFormat
        imageManager.requestImageForAsset(asset,
            targetSize: previewSize,
            contentMode: .AspectFit,
            options: requestOptions,
            resultHandler: { [weak self] (image, info) -> Void in
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    self?.profileImageView.image = image
                })
            })
    }
    
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
}

