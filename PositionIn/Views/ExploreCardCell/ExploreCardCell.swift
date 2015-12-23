
//
//  ExploreCardCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 23/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class ExploreCardCell: TableViewCell {

    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
//        feedItemImageView.setImageFromURL(m!.imageURL)
        
        headerLabel.text = m!.title
        infoLabel.text = m!.info
        detailsLabel.text = m!.details
    }
    
    @IBOutlet private weak var feedItemImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var feedItemLogoImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}