//
//  PostLikeCommentCell.swift
//  PositionIn
//
//  Created by mpol on 9/29/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

protocol PostLikeCommentCellDelegate {
    
}

class PostLikeCommentCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? PostLikesCountModel
        assert(m != nil, "Invalid model passed")
        
        self.amountOfCommentsLabel.text = String(m!.comments)
        self.amountOfLikesLabel.text = String(m!.likes)
        self.actionConsumer = m!.actionConsumer
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        actionConsumer?.likePost()
    }
    @IBOutlet weak var amountOfCommentsLabel: UILabel!
    @IBOutlet weak var amountOfLikesLabel: UILabel!
    weak var actionConsumer: PostActionConsumer?
}
