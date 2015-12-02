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
    var descr: String?
    var details: String?
    var text: String?
    var category: ItemCategory?
    var price: Float?
    var donations: Float?
    var startDate: NSDate?
    var endDate: NSDate?
    var author: ObjectInfo?
    var community: CRUDObjectId = CRUDObjectInvalidId
    var date: NSDate?
    var image: NSURL?
    var type: ItemType = .Unknown
    var location: Location?
    
    var itemData: Any? {
        switch type {
        case .Project:
            return author
        case .Training:
            return author
        default:
            return nil
        }
    }
    
    init(name: String, details: String, text: String, price: Float) {
        self.name = name
        self.details = details
        self.text = text
        self.price = price
    }
    
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
        descr <- map["desctiption"]
        details <- map["details"]
        text <- map["text"]
        category <- (map["category"], EnumTransform())
        price <- map["price"]
        donations <- map["donations"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
        author <- map["author"]
        community <- (map["community"], CRUDObjectIdTransform())
        date <- (map["date"], APIDateTransform())
        image <- (map["image"], AmazonURLTransform())
        type <- (map["type"], EnumTransform())
        location <- map["location"]        
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
    
    enum ItemType: Int, CustomStringConvertible {
        case Unknown
        case Project
        case Emergency
        case Training
//        case Event
//        case Promotion
//        case Item
//        case Post
//        
        var description: String {
            switch self {
            case .Unknown:
                return "Unknown/All"
            case .Project:
                return "Project"
            case .Emergency:
                return "Emergency"
            case Training:
                return "Training"
            }
        }
    }
    
    static func endpoint() -> String {
        return "/v1.0/search"
    }
    
    static func forYouEndpoint() -> String {
        return "/v1.0/recommended"
    }
    
    static func getAllEndpoint() -> String {
        return "/v1.0/getAllByType"
    }
    
    static func getOneEndpoint(objectId: CRUDObjectId) -> String {
        return "/v1.0/getOneById/\(objectId)"
    }
}
