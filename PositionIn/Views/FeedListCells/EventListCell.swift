//
//  EventListCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/20/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import UIKit

final class EventListCell: TableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
        switch m!.itemType {
        case Unknown:
            break
//        case Project:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case Emergency:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case Training:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case GiveBlood:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case News:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case Event:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case Market:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case BomaHotels:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
//        case Volunteer:
//            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
        }

        titleLabel.text = m!.title
        infoLabel.text = m!.info
        dateLabel.text = m!.details
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
    
}