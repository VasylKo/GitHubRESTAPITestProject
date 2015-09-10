//
//  PeopleListCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 10/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class PeopleListCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? UserInfoTableViewCellModel
        assert(m != nil, "Invalid model passed")
        avatarView.setImageFromURL(m!.userInfo.avatar)
        nameLabel.text = m!.userInfo.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
     
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var avatarView: AvatarView!
}

struct UserInfoTableViewCellModel: TableViewCellModel {
    let userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
}
