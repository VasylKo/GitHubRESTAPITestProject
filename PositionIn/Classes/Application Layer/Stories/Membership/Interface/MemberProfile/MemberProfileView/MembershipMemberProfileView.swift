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

protocol MembershipMemberProfileViewDelegate {
    func addPhoto()
}

class MembershipMemberProfileView : UIView {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var addPhotoLabel: UILabel!

    var asset : PHAsset?
    var delegate : MembershipMemberProfileViewDelegate?
    
    override func awakeFromNib() {
        self.addPhotoLabel.textColor = UIScheme.mainThemeColor
        self.profileImageView.layer.masksToBounds = true
    }
    
    @IBAction func addPhotoAction(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.addPhoto()
        }
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
                    self?.profileImageView.layer.masksToBounds = true
                    self?.profileImageView.image = image
                    self?.addPhotoLabel.alpha = 0.0
                })
            })
    }
    
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
}

