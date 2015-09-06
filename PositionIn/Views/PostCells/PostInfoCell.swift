//
//  ProductActionCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class PostInfoCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? PostInfoModel
        assert(m != nil, "Invalid model passed")
        avatarView.setImageFromURL(m!.imageUrl)
        firstLineLabel.text = m!.firstLine
        secondLineLabel.text = m!.secondLine
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
    }

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
}
