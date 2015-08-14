//
//  ProfileInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import Haneke

final class ProfileInfoCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? ProfileInfoCellModel
        assert(m != nil, "Invalid model passed")
        nameLabel.text = m!.name
        m!.avatar.map { self.avatarView.setImageFromURL($0) }
        m!.background.map { self.backImageView.hnk_setImageFromURL($0) }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backImageView.hnk_cancelSetImage()
        avatarView.cancelSetImage()
    }
    
    @IBOutlet private weak var backImageView: UIImageView!
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    
}

public struct ProfileInfoCellModel: ProfileCellModel {
    let name: String?
    let avatar: NSURL?
    let background: NSURL?
}
