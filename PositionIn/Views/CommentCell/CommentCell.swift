//
//  CommentCell.swift
//  PositionIn
//
//  Created by mpol on 9/30/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class CommentCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? PostCommentCellModel
        assert(m != nil, "Invalid model passed")
        avatarView.setImageFromURL(m!.imageUrl)
        userNameLabel.text = m!.name
        commentLabel.text = m!.comment
        dateLabel.text = m!.date
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    
}
