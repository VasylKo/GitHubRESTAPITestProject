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

protocol FeedTableCellModel: TableViewCellModel {
    var itemType: FeedItem.ItemType { get }
    var objectID: CRUDObjectId { get }
    var data: Any? { get }
}

class CompactFeedTableCellModel: FeedTableCellModel {
    
    let itemType: FeedItem.ItemType
    let objectID: CRUDObjectId
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
    
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, text: String?, price: Float?, imageURL: NSURL?, avatarURL:NSURL?, location: Location? = nil, numOfLikes: Int? = nil, numOfComments: Int? = nil, date: NSDate?, data: Any? = nil) {
        self.objectID = objectID
        self.itemType = itemType
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
        self.date = date
        self.text = text
        
        switch itemType {
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
        case .Unknown:
            break
        }
    }
}

final class ComapctBadgeFeedTableCellModel : CompactFeedTableCellModel {
    let badge: String?
    
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, text: String?, imageURL: NSURL?, avatarURL:NSURL?, badge: String?, data: Any?) {
        self.badge = badge
        super.init(itemType: itemType,
            objectID: objectID,
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
