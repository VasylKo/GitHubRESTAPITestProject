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
    
    var delegate : MembershipMemberProfileViewDelegate?
    
    override func awakeFromNib() {
        self.addPhotoLabel.textColor = UIScheme.mainThemeColor
    }
    
    @IBAction func addPhotoAction(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.addPhoto()
        }
    }
    
    func configure (profileImage : UIImage) {
        self.profileImageView.image = profileImage
    }
    
}

