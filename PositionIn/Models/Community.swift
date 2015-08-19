//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Community: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var communityDescription: String?
    var avatar: NSURL?
    var isPrivate: Bool = false
    /*
    "members": {
    "data": [
				{
    "id": <guid>,
    "name": <string>,
    "avatar": <string>
				}
				],
    "count": <number>
    },
    */
    var role: String?
    var members: CollectionResponse<UserProfile>?
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
        communityDescription <- map["description"]
        role <- map["role"]
        avatar <- (map["avatar"], URLTransform())
        isPrivate <- map["isPrivate"]
        members <- map["members"]
        location <- map["location"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/community"
    }

    static func communityEndpoint(communityId: CRUDObjectId) -> String {
        return Community.endpoint().stringByAppendingPathComponent("\(communityId)")
    }

    
    static func userCommunitiesEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent("\(userId)/communities")
    }
    
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}