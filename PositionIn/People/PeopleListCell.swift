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
        let m = model as? TableViewCellURLTextModel
        assert(m != nil, "Invalid model passed")
        avatarView.setImageFromURL(m!.url)
        nameLabel.text = m!.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
     
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
}
