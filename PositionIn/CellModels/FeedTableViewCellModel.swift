//
//  TableViewCellModels.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

protocol FeedTableCellModel: TableViewCellModel {
    var itemType: FeedItem.ItemType { get }
    var objectID: CRUDObjectId { get }
}

class CompactFeedTableCellModel: FeedTableCellModel {
    
    let itemType: FeedItem.ItemType
    let objectID: CRUDObjectId
    
    let title: String?
    let details: String?
    let info: String?
    let imageURL: NSURL?
    
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, imageURL url: NSURL?) {
        self.objectID = objectID
        self.itemType = itemType
        self.title = title
        self.info = info
        self.details = details
        self.imageURL = url
    }
}

class ComapctBadgeFeedTableCellModel : CompactFeedTableCellModel {
    let badge: String?
    init(itemType: FeedItem.ItemType, objectID: CRUDObjectId, title: String?, details: String?, info: String?, imageURL url: NSURL?, badge: String?) {
        self.badge = badge
        super.init(itemType: itemType, objectID: objectID, title: title, details: details, info: info, imageURL: url)
    }
}

