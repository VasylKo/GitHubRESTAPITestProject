//
//  PostLikeCommentCell.swift
//  PositionIn
//
//  Created by mpol on 9/29/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class PostLikeCommentCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? PostLikesCountModel
        assert(m != nil, "Invalid model passed")
        
        let image = m!.isLiked == true ? UIImage(named:"ic_like_selected") : UIImage(named:"ic_like_up")
        self.likeButton.setImage(image, forState: .Normal)
        
        self.amountOfCommentsLabel.text = String(m!.comments)
        self.amountOfLikesLabel.text = String(m!.likes)
        self.actionConsumer = m!.actionConsumer
        likeButton.userInteractionEnabled = true
        
        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        containerView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 0.0
        containerView.layer.masksToBounds = false
        
        self.selectionStyle = .None
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        likeButton.userInteractionEnabled = false
        actionConsumer?.likePost()
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var amountOfCommentsLabel: UILabel!
    @IBOutlet weak var amountOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var actionConsumer: NewsActionConsumer?
}
