//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Post: CRUDObject {
    private(set) var objectId: CRUDObjectId
    var name: String?
    var text: String?
    var location: Location?
    
    init(objectId: CRUDObjectId) {
        self.objectId = objectId
    }
    
    init?(_ map: Map) {
        mapping(map)
        switch (objectId) {
        case (.Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }

    mutating func mapping(map: Map) {
        objectId <- map["id"]
        name <- map["name"]
        text <- map["text"]
        location <- map["location"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/post"
    }
    
    static func allEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent(userId).stringByAppendingPathComponent("posts")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}