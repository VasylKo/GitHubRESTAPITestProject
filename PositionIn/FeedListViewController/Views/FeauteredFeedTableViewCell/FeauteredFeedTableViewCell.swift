//
//  FeauteredFeedTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class FeauteredFeedTableViewCell: UITableViewCell {
    
    func setImageURL(imageURL: NSURL?, placeholder: String?) {
        let imagePlaceholder: String = placeholder ?? ""
        self.feedItemImageView.setImageFromURL(imageURL, placeholder:UIImage(named: imagePlaceholder))
    }
    
    var titleString: String? {
        didSet {
            self.titleLabel.text = titleString
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleLabelContainerView.backgroundColor = UIColor.bt_colorFromHex("000000", alpha: 0.5)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        titleLabelContainerView.backgroundColor = UIColor.bt_colorFromHex("000000", alpha: 0.5)
    }
    
    @IBOutlet weak var titleLabelContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var feedItemImageView: UIImageView!
}