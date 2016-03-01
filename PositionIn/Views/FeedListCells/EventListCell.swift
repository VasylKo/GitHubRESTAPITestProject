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

        //todo: need update images
        
        switch m!.item.type {
        case .Emergency:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "PromotionDetailsPlaceholder"))
        case .GiveBlood:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "give_blood_img_default"))
        case .Training:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "trainings_placeholder"))
        case .Market:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "market_img_default"))
        case .BomaHotels:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "bomaHotelPlaceholder"))
        case .Project:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "hardware_img_default"))
        case .Event:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "eventDetailsPlaceholder"))
        case .News:
            productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
        case .Unknown:
            break
        default:
            break
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