//
//  TableViewCellModels.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import CoreLocation

protocol ActionsDelegate: class {
    func like(item: FeedItem)
}

protocol FeedTableCellModel: TableViewCellModel {
    weak var delegate: ActionsDelegate? { get }
    var item: FeedItem { get }
    var data: Any? { get }
}

class CompactFeedTableCellModel: FeedTableCellModel {
    
    let item : FeedItem
    let data: Any?
    
    let title: String?
    let details: String?
    var info: String?
    let price: Float?
    let imageURL: NSURL?
    let avatarURL: NSURL?
    let location: Location?
    let text : String?
    let date: NSDate?
    var numOfLikes: Int?
    var numOfComments: Int?
    var numOfParticipants: Int?
    
    weak var delegate : ActionsDelegate?
    
    init(delegate : ActionsDelegate?, item : FeedItem, title: String?, details: String?, info: String?, text: String?, price: Float?, imageURL: NSURL?, avatarURL:NSURL?, location: Location? = nil, numOfLikes: Int? = nil, numOfComments: Int? = nil,
        numOfParticipants: Int? = nil,  date: NSDate?, data: Any? = nil) {
        self.item = item
        self.delegate = delegate
        self.title = title
        self.info = info
        self.details = details
        self.imageURL = imageURL
        self.avatarURL = avatarURL
        self.price = price
        self.data = data
        self.location = location
        self.numOfLikes = numOfLikes
        self.numOfComments = numOfComments
        self.numOfParticipants = numOfParticipants
        self.date = date
        self.text = text
        
        switch self.item.type {
        case .Emergency:
            fallthrough
        case .GiveBlood:
            fallthrough
        case .Training:
            fallthrough
        case .Volunteer:
            fallthrough
        case .Market:
            fallthrough
        case .BomaHotels:
            if let location = location {
                locationController().distanceFromCoordinate(location.coordinates).onSuccess {
                    [weak self] distance in
                    let formatter = NSLengthFormatter()
                    formatter.numberFormatter.maximumFractionDigits = 1
                    formatter.unitStyle = .Long
                    self?.info = formatter.stringFromMeters(distance)
                }
            }
        case .Project:
            if let price = price {
                self.info = "\(Int(price)) beneficiaries"
            }
        case .Event:
            //attend
            fallthrough
        case .News:
            fallthrough
        case .Post:
            fallthrough
        case .Wallet:
            fallthrough
        case .Unknown:
            break
        }
    }
}

final class ComapctBadgeFeedTableCellModel : CompactFeedTableCellModel {
    let badge: String?
    
    init(delegate: ActionsDelegate?,item: FeedItem, title: String?, details: String?, info: String?, text: String?, imageURL: NSURL?, avatarURL:NSURL?, badge: String?, data: Any?) {
        self.badge = badge
        super.init(delegate: delegate,
            item: item,
            title: title,
            details: details,
            info: info,
            text: text,
            price: nil,
            imageURL: imageURL,
            avatarURL: avatarURL,
            date: nil,
            data: data)
    }
}
