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
    
    init(item: FeedItem, title: String?, details: String?, info: String?, imageURL url: NSURL?) {
        self.objectID = item.objectId
        self.itemType = item.type
        self.title = item.name
        self.info = info
        self.details = item.text
        self.imageURL = url
    }
}

class ComapctPriceFeedTableCellModel : CompactFeedTableCellModel {
    let price: Int?
    init(item: FeedItem, title: String?, details: String?, info: String?, imageURL url: NSURL?, price: Double?) {
        self.price = item.price
        super.init(item: item, title: title, details: details, info: info, imageURL: url)
    }
}

