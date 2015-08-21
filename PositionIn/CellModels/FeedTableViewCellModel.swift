//
//  TableViewCellModels.swift
//  PositionIn
//
//  Created by Xenia Chugunova on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

protocol FeedTableItemCellModel: TableViewCellModel {
    var itemType: FeedItem.Type { get }
    var objectID: CRUDObjectId { get }
}

class CompactFeedTableItemCellModel: TableViewCellModel {
    let title: String
    let info: String
    let imageURL: NSURL?
    let itemType: FeedItem.Type
    let objectID: CRUDObjectId

}

public struct TableViewCellTitleImagePriceDistanceModel: TableViewCellModel {
    public let title: String
    public let owner: String
    public let price: CGFloat
    public let distance: CGFloat
    public let imageURL: String
    
    public init(title: String, owner: String, distance: CGFloat, imageURL: String, price: CGFloat) {
        self.title = title
        self.owner = owner
        self.distance = distance
        self.imageURL = imageURL
        self.price = price
    }
}

public struct TableViewCellTitleImageDateInfoModel: TableViewCellModel {
    public let title: String
    public let date: NSDate
    public let info: String
    public let imageURL: String
    
    public init(title: String, date: NSDate, info: String, imageURL: String) {
        self.title = title
        self.date = date
        self.info = info
        self.imageURL = imageURL
    }
}

public struct TableViewCellTitleImageInfoModel: TableViewCellModel {
    public let title: String
    public let info: String
    public let imageURL: String
    
    public init(title: String, info: String, imageURL: String) {
        self.title = title
        self.info = info
        self.imageURL = imageURL
    }
}

public struct TableViewCellTitleImageAuthorDiscountModel: TableViewCellModel {
    public let title: String
    public let author: String
    public let discount: String
    public let imageURL: String
    
    public init(title: String, author: String, discount: String, imageURL: String) {
        self.title = title
        self.author = author
        self.discount = discount
        self.imageURL = imageURL
    }
}