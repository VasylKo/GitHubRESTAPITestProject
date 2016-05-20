//
//  NewsCardCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class NewsCardCell: TableViewCell {
    
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var imageHeightConstaint: NSLayoutConstraint!
    @IBOutlet private weak var feedItemImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var feedItemAvatarView: AvatarView!
    @IBOutlet private weak var newsTextLabel: UILabel!
    
    private var item : FeedItem?
    private weak var actionConsumer: ActionsDelegate?
    
    override func setModel(model: TableViewCellModel) {
        
        likeButton.userInteractionEnabled = true
        
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
        self.actionConsumer = m!.delegate
        self.item = m!.item
        
        if let liked = self.item?.isLiked {
            let image = liked == true ? UIImage(named:"ic_like_selected") : UIImage(named:"ic_like_up")
            self.likeButton.setImage(image, forState: .Normal)
        }
        
        if let imgURL = m!.imageURL {
            feedItemImageView.setImageFromURL(imgURL)
            self.imageHeightConstaint.constant = 160
        }
        else {
            feedItemImageView.image = nil
            self.imageHeightConstaint.constant = 0
        }
        
        headerLabel.text = m!.authorName
        
        detailsLabel.hidden = true
        if let date = m!.date {
            detailsLabel.hidden = false
            detailsLabel.text = date.formattedAsTimeAgo()
        }
        
        infoLabel.text = m!.details
        
        if let numOfLikes = self.item?.numOfLikes {
            likeButton.setTitle(String(numOfLikes), forState: .Normal)
        }
        
        if let numOfComments = m!.numOfComments {
            commentsButton.setTitle(String(numOfComments), forState: .Normal)
        }
        
        if let text = m!.text {
            self.newsTextLabel.text = text
        }
        
        feedItemAvatarView.setImageFromURL(m!.item.author?.avatar)
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        likeButton.userInteractionEnabled = false
        actionConsumer?.like(self.item!)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        feedItemAvatarView.cancelSetImage()
    }
}