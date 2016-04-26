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
    
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet private weak var imageHeightConstaint: NSLayoutConstraint!
    @IBOutlet private weak var feedItemImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var feedItemAvatarView: AvatarView!
    @IBOutlet private weak var newsTextLabel: UILabel!
    
    private var model : CompactFeedTableCellModel?
    
    override func setModel(model: TableViewCellModel) {
        
        self.model = model as? CompactFeedTableCellModel
        assert(self.model != nil, "Invalid model passed")
        
        
        if let liked = self.model?.item.isLiked {
            let image = liked == true ? UIImage(named:"ic_like_selected") : UIImage(named:"ic_like_up")
            self.likesButton.setImage(image, forState: .Normal)
        }
        
        if let imgURL = self.model?.imageURL {
            feedItemImageView.setImageFromURL(imgURL)
            self.imageHeightConstaint.constant = 160
        }
        else {
            feedItemImageView.image = nil
            self.imageHeightConstaint.constant = 0
        }
        
        headerLabel.text = self.model?.authorName
        
        detailsLabel.hidden = true
        if let date = self.model?.date {
            detailsLabel.hidden = false
            detailsLabel.text = date.formattedAsTimeAgo()
        }
        
        infoLabel.text = self.model?.details
        
        if let numOfLikes = self.model?.numOfLikes {
            likesButton.setTitle(String(numOfLikes), forState: .Normal)
        }
        
        if let numOfComments = self.model?.numOfComments {
            commentsButton.setTitle(String(numOfComments), forState: .Normal)
        }
        
        if let text = self.model?.text {
            self.newsTextLabel.text = text
        }
        
        if let url = self.model?.avatarURL {
            feedItemAvatarView.setImageFromURL(url)
        }
    }
    
    @IBAction func likesButtonPressed(sender: AnyObject) {
        if let delegate = self.model?.delegate,
            let item = self.model?.item  {
                delegate.like(item)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedItemAvatarView.cancelSetImage()
    }
}