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
        
        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        containerView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 0.0
        containerView.layer.masksToBounds = false
        
        self.selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    
}
