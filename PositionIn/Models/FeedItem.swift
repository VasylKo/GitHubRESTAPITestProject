//
//  FeedItem.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct FeedItem: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var price: Int?
    var text: String?
    var details: String?
    var date: NSDate?
    var image: NSURL?
    var type: ItemType = .Unknown
    var location: Location?
    var startDate: NSDate?
    var endDate: NSDate?
    var discount: Float?
    
    var author: CRUDObjectId = CRUDObjectInvalidId
    var community: CRUDObjectId = CRUDObjectInvalidId
    
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
        date <- (map["date"], APIDateTransform())
        text <- map["text"]
        image <- (map["image"], AmazonURLTransform())
        type <- (map["type"], EnumTransform())
        location <- map["location"]
        details <- map["details"]
        author <- map["author"]
        community <- map["community"]
        name <- map["name"]
        price <- map["price"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        discount <- map["discount"]
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }

    
    enum ItemType: Int {
        case Unknown
        case Event
        case Promotion
        case Item
        case Person
        case Post
    }
    
    static func endpoint() -> String {
        return "/v1.0/search"
    }
}
