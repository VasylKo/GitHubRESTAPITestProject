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
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var infoLabel: UILabel?
    
    // MARK: - TableViewCell
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")

        //todo: need update images
        
        switch m!.item.type {
        case .Emergency:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "PromotionDetailsPlaceholder"))
        case .GiveBlood:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "give_blood_img_default"))
        case .Training:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "trainings_placeholder"))
        case .Market:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "market_img_default"))
        case .BomaHotels:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "bomaHotelPlaceholder"))
        case .Project:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "hardware_img_default"))
        case .Event:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "eventDetailsPlaceholder"))
        case .News:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
        case .Wallet:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "market_img_default"))
        case .Unknown:
            break
        default:
            break
        }
        
        titleLabel?.text = m!.title
        
        if m!.item.type == FeedItem.ItemType.Event {
            let eventDetailsFormat = NSLocalizedString("%d People are attending", comment: "Event details: details format")
            infoLabel?.text = String(format: eventDetailsFormat, m!.numOfParticipants ?? 0)
            
            if let date = m!.date {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM, hh:mm a"
                let date = dateFormatter.stringFromDate(date)
                dateLabel?.text = date
            }

        }
        else {
            infoLabel?.text = m!.info
            dateLabel?.text = m!.details
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage?.hnk_cancelSetImage()
    }
}