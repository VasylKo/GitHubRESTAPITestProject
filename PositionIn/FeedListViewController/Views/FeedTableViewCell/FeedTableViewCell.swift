//
//  FeedTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    func setImageURL(imageURL: NSURL?, placeholder: String?) {
        let imagePlaceholder: String = placeholder ?? ""
        self.feedItemImageView.setImageFromURL(imageURL, placeholder:UIImage(named: imagePlaceholder))
    }
    
    var titleString: String? {
        didSet {
            self.titleLabel.text = titleString
        }
    }
    
    var timeAgoString: String? {
        didSet {
            self.timeAgoLabel.text = timeAgoString
        }
    }
    
    var authorString: String? {
        didSet {
            self.authorLabel.text = authorString
        }
    }
    
    @IBOutlet private weak var timeAgoLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var feedItemImageView: UIImageView!
}
