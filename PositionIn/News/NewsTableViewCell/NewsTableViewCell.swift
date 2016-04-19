//
//  NewsTableViewCell.swift
//  PositionIn
//
//  Created by ng on 2/18/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

class NewsTableViewCell: TableViewCell {
    
    private weak var actionConsumer: NewsListActionConsumer?
    private var item : FeedItem?
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet private weak var imageHeightConstaint: NSLayoutConstraint!
    @IBOutlet private weak var feedItemImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var feedItemAvatarView: AvatarView!
    @IBOutlet private weak var newsTextLabel: UILabel!
    
    //MARK: Set model
    
    override func setModel(model: TableViewCellModel) {
        likeButton.userInteractionEnabled = true
        
        let m = model as? NewsTableViewCellModel
        assert(m != nil, "Invalid model passed")
        
        self.item = m!.item
        
        if let liked = self.item?.isLiked {
            let image = liked == true ? UIImage(named:"ic_like_selected") : UIImage(named:"ic_like_up")
            self.likeButton.setImage(image, forState: .Normal)
        }
        
        feedItemImageView.setImageFromURL(m!.item.image, placeholder: UIImage(named: "news_placeholder"))
        self.imageHeightConstaint.constant = 160
        
        headerLabel.text = m!.item.name
        if let date = m!.item.date {
            detailsLabel.text = date.formattedAsTimeAgo()
        }
        
        if let likes = m!.item.numOfLikes {
            likeButton.setTitle(String(likes), forState: .Normal)
        }
        
        if let comments = m!.item.numOfComments {
            commentButton.setTitle(String(comments), forState: .Normal)
        }
        
        if let text = m!.item.text {
            self.newsTextLabel.text = text
        }
        
        if let url = m!.item.author?.avatar {
            feedItemAvatarView.setImageFromURL(url)
        }
        
        self.actionConsumer = m!.actionConsumer
    }
    
    //MARK: Actions
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        likeButton.userInteractionEnabled = false
        actionConsumer?.like(self.item!)
    }
    
    //MARK: Other
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedItemAvatarView.cancelSetImage()
    }
}