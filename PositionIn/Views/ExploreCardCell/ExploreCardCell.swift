
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
        
        switch m!.itemType {
        case .Emergency:
            feedItemLogoImageView.image = UIImage(named: "home_emergencies")
        case .GiveBlood:
            feedItemLogoImageView.image = UIImage(named: "home_blood")
        case .Training:
            feedItemLogoImageView.image = UIImage(named: "home_training")
        case .Volunteer:
            feedItemLogoImageView.image = UIImage(named: "home_volunteer")
        case .Market:
            feedItemLogoImageView.image = UIImage(named: "home_market")
        case .BomaHotels:
            feedItemLogoImageView.image = UIImage(named: "home_hotel")
        case .Project:
            feedItemLogoImageView.image = UIImage(named: "home_projects")
        case .Event:
            feedItemLogoImageView.image = UIImage(named: "home_event")
        case .News:
            feedItemLogoImageView.image = UIImage(named: "home_news")
        case .Unknown:
            break
        }
        
        feedItemImageView.setImageFromURL(m!.imageURL)
        
        headerLabel.text = m!.title
        infoLabel.text = m!.info
        detailsLabel.text = m!.details
    }
    
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