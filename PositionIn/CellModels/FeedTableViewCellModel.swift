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
    let info: String?
    let price: Float?
    let imageURL: NSURL?
    let location: Location?
    
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, price: Float?, imageURL url: NSURL?, location: Location?, data: Any? = nil) {
        self.objectID = objectID
        self.itemType = itemType
        self.title = title
        self.info = info
        self.details = details
        self.imageURL = url
        self.price = price
        self.data = data
        self.location = location
    }
}


final class ComapctBadgeFeedTableCellModel : CompactFeedTableCellModel {
    let badge: String?
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, imageURL url: NSURL?, badge: String?, data: Any?) {
        self.badge = badge
        super.init(itemType: itemType, objectID: objectID, title: title, details: details, info: info, price: nil, imageURL: url, location: nil,data: data)
    }
}

