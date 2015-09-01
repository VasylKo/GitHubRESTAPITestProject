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
    var descriptionEvent: String?
    var category: Int = 1
    //"date": <datetime>,
    var photos: [PhotoInfo]?
    var likes: Int?
    
    var endDate: NSDate?
    var startDate: NSDate?
    /*
    "comments": {
    data:[],
    count: <number>
    },
    */
    /*
    "author": {
    "id": <guid>,
    "name": <string>,
    "avatar": <string>
    },
    */
    var location: Location?
    
    
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
        let dateTransform =  CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        
        objectId <- (map["id"], CRUDObjectIdTransform())
        name <- map["name"]
        descriptionEvent <- map["description"]
        photos <- map["photos"]
        likes <- map["likes"]
        location <- map["location"]
        category <- map["category"]
        endDate <- (map["endDate"], dateTransform)
        startDate <- (map["startDate"], dateTransform)
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