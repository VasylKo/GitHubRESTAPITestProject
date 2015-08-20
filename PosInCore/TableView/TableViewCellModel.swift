//
//  TableViewCellModel.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

public protocol TableViewCellModel {
    
}

public struct  TableViewCellInvalidModel: TableViewCellModel {
    public init() {
    }    
}

public struct TableViewCellTextModel: TableViewCellModel {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct TableViewCellImageTextModel: TableViewCellModel {
    public let title: String
    public let image: String
    
    public init(title: String, imageName: String) {
        self.title = title
        image = imageName
    }
    
}

public struct TableViewCellProductModel: TableViewCellModel {
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

public struct TableViewCellEventModel: TableViewCellModel {
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

public struct TableViewCellPostModel: TableViewCellModel {
    public let title: String
    public let info: String
    public let imageURL: String
    
    public init(title: String, info: String, imageURL: String) {
        self.title = title
        self.info = info
        self.imageURL = imageURL
    }
}

public struct TableViewCellPromotionModel: TableViewCellModel {
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