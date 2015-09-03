//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Event: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var eventDescription: String?
    var endDate: NSDate?
    var startDate: NSDate?
    var photos: [PhotoInfo]?
    var location: Location?
    var category: ItemCategory?

   
    
/* 
    Todo:
    "items": [<guid>],
*/
    
/*
    
    Not send
    
"attendees": <number>,
"author": {
    "id": <guid>,
    "name": <string>,
    "avatar": <string>,
    "isCommunity": <bool>
},
    
*/
    
/*
    Details
    
    
    "shop": <guid>,
    "items": [{
        "data":{
        "id": <guid>,
        "name": <string>,
        "photos": [{
				"id": <guid>,
				"url": <string>
				}]
        },
        "count": <number>
    }],
    "participants": {
        "count": <number>
    },
    
    "author": <guid?>,
    "community": <guid?>,
    
*/
    
    
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
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
        eventDescription <- map["description"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
        photos <- map["photos"]
        location <- map["location"]
        category <- (map["category"], EnumTransform())
    }
    
    static func endpoint() -> String {
        return "/v1.0/events"
    }
    
    static func endpoint(eventId: CRUDObjectId) -> String {
        return "/v1.0/events/\(eventId)"
    }
    
    static func userEventsEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent("\(userId)/events")
    }
    
    static func communityEventsEndpoint(communityId: CRUDObjectId) -> String {
        return Community.endpoint().stringByAppendingPathComponent("\(communityId)/events")
    }
    
    static func allEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent(userId).stringByAppendingPathComponent("events")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}