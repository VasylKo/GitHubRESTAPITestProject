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
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .GiveBlood:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "give_blood_img_default"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .Training:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "trainings_placeholder"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .Market:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "market_img_default"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .BomaHotels:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "bomaHotelPlaceholder"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .Project:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "hardware_img_default"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .Event:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "eventDetailsPlaceholder"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .News:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "placeholderEvent"))
            configureAttendingInfo(m!.numOfParticipants ?? 0)
        case .Wallet:
            productImage?.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "market_img_default"))
            infoLabel?.text = m!.info
        case .Unknown:
            break
        default:
            break
        }
        
        titleLabel?.text = m!.title
        dateLabel?.text = m!.details
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage?.hnk_cancelSetImage()
    }
    
    // MARK: - Private functions
    private func configureAttendingInfo(numOfParticipants: Int) {
        let attendingInfoFormat = NSLocalizedString("%d People are attending", comment: "Event details: details format")
        infoLabel?.text = String(format: attendingInfoFormat, numOfParticipants)
    }
}