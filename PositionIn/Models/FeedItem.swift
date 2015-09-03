//
//  FeedItem.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

//TODO: clean from invalid ivars

struct FeedItem: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?    
    var details: String?
    var text: String?
    var category: ItemCategory?
    var price: Float?
    var startDate: NSDate?
    var endDate: NSDate?
    var author: CRUDObjectId = CRUDObjectInvalidId
    var community: CRUDObjectId = CRUDObjectInvalidId
    var date: NSDate?
    var image: NSURL?
    var type: ItemType = .Unknown
    var location: Location?
    
    
    
    
    init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        name <- map["name"]
        details <- map["details"]
        text <- map["text"]
        category <- (map["category"], EnumTransform())
        price <- map["price"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
        author <- (map["author"], CRUDObjectIdTransform())
        community <- (map["community"], CRUDObjectIdTransform())
        date <- (map["date"], APIDateTransform())
        image <- (map["image"], AmazonURLTransform())
        type <- (map["type"], EnumTransform())
        location <- map["location"]        
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }

    
    enum ItemType: Int {
        case Unknown
        case Event
        case Promotion
        case Item
        case Post
    }
    
    static func endpoint() -> String {
        return "/v1.0/search"
    }
}
