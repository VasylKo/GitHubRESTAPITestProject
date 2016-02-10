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
    var descriptionString: String?
    var photoURL: NSURL?
    var location: Location?
    
    var likes: Int = 0
    var isLiked: Bool = false
    var author: UserInfo?
    var comments: [Comment] = []
    var date: NSDate?
    var communityID: String?
    
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
        descriptionString <- map["description"]
        photoURL <- (map["image"], AmazonURLTransform())
        likes <- map["numOfLikes"]
        location <- map["location"]
        isLiked <- map["isLiked"]
        author <- map["author"]
        comments <- map["comments"]
        communityID <- map["communityId"]
        date <- (map["date"], APIDateTransform())        
    }
    
    static func endpoint() -> String {
        return "/v1.0/posts"
    }

    static func endpoint(postId: CRUDObjectId) -> String {
        return (Post.endpoint() as NSString).stringByAppendingPathComponent("\(postId)")
    }
    
    static func likeEndpoint(postId: CRUDObjectId) -> String {
        return (Post.endpoint() as NSString).stringByAppendingPathComponent("\(postId)/like")
    }
    
    static func postCommentEndpoint(postId: CRUDObjectId) -> String {
        return (Post.endpoint() as NSString).stringByAppendingPathComponent("\(postId)/comment")
    }
    
    static func userPostsEndpoint(userId: CRUDObjectId) -> String {
        return (UserProfile.endpoint() as NSString).stringByAppendingPathComponent("\(userId)/posts")
    }
    
    static func communityPostsEndpoint() -> String {
        return "/v1.0/posts"
    }
        
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}