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
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var text: String?
    var photos: [PhotoInfo]?
    var location: Location?
    
    var likes: Int?
    
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
        text <- map["text"]
        photos <- map["photos"]
        likes <- map["likes"]
        location <- map["location"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/posts"
    }

    static func endpoint(postId: CRUDObjectId) -> String {
        return Post.endpoint().stringByAppendingPathComponent("\(postId)")
    }
    
    static func userPostsEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent("\(userId)/posts")
    }
    
    static func communityPostsEndpoint(communityId: CRUDObjectId) -> String {
        return Community.endpoint().stringByAppendingPathComponent("\(communityId)/posts")
    }
        
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}