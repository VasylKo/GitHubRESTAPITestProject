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
    var text: String?
    var endDate: NSDate?
    var startDate: NSDate?
    var photos: [PhotoInfo]?
    var location: Location?
    var category: ItemCategory?
    var participants: Int? = 0
    var author: CRUDObjectId?
    var imageURL: NSURL?
    var links : [NSURL]?
    var attachments : [Attachment]?
    var isAttending: Bool?
    
/* 
    TODO:
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
        text <- map["description"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
        photos <- map["photos"]
        location <- map["location"]
        category <- (map["category"], EnumTransform())
        participants <- map["numOfParticipants"]
        author <- (map["author"], CRUDObjectIdTransform())
        imageURL <- (map["image"], AmazonURLTransform())
        links <- (map["links"], URLTransform())
        attachments <- map["attachments"]
        isAttending <- map["isAttending"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/events"
    }
    
    static func endpoint(eventId: CRUDObjectId) -> String {
        return (Event.endpoint() as NSString).stringByAppendingPathComponent("\(eventId)")
    }
    
    static func endpointAttend(eventId: CRUDObjectId) -> String {
        return (Event.endpoint() as NSString).stringByAppendingPathComponent("\(eventId)/members")
    }
    
    static func userEventsEndpoint(userId: CRUDObjectId) -> String {
            return (UserProfile.userEndpoint(userId) as NSString).stringByAppendingPathComponent("events")
    }
    
    static func communityEventsEndpoint(communityId: CRUDObjectId) -> String {
        return (Community.endpoint() as NSString).stringByAppendingPathComponent("\(communityId)/events")
    }
        
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}