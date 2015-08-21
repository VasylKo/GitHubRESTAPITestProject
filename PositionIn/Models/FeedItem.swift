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
    var text: String?
    var date: NSDate?
    var image: NSURL?
    var type: Type = .Unknown
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
        date <- (map["date"], APIDateTransform())
        text <- map["text"]
        image <- (map["image"], URLTransform())
        type <- (map["type"], EnumTransform())
        location <- map["location"]

    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }

    
    enum Type: Int {
        case Unknown
        case Event
        case Promotion
        case Item
        case Person
        case Post
    }
    
    static func endpoint() -> String {
        return "/v1.0/feed"
    }
}
