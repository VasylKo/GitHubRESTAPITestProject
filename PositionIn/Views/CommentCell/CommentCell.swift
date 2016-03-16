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
        
        self.containerView.layer.cornerRadius = 2
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        containerView.layer.shadowOpacity = 0.1
        
        self.selectionStyle = .None
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.frame = CGRect(origin: CGPoint(x: 8, y: 8),
            size: CGSizeMake(self.bounds.size.width - 16, self.bounds.size.height - 16))
        let shadowPath = UIBezierPath(rect: containerView.bounds)
        containerView.layer.shadowPath = shadowPath.CGPath
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
