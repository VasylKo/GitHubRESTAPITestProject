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
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
        if let imgURL = m!.imageURL {
            feedItemImageView.setImageFromURL(imgURL)
            self.imageHeightConstaint.constant = 80
        }
        else {
            feedItemImageView.image = nil
            self.imageHeightConstaint.constant = 0
        }
        
        
        headerLabel.text = m!.title
        infoLabel.text = m!.info
        detailsLabel.text = m!.details
        
        if let numOfLikes = m!.numOfLikes {
            likesLabel.text = String(numOfLikes)
        }
        
        if let numOfComments = m!.numOfComments {
            commentsLabel.text = String(numOfComments)
        }
    }
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet private weak var imageHeightConstaint: NSLayoutConstraint!
    @IBOutlet private weak var feedItemImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var feedItemLogoImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}