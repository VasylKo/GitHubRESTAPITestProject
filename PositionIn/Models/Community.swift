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
    
    var shops: [ObjectInfo]?

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
    var membersCount: Int = 0
    var postsCount: Int = 0
    var eventsCount: Int = 0
    
    var role: Role = .Unknown
    var members: CollectionResponse<UserInfo>?
    var location: Location?
    
    var defaultShopId: CRUDObjectId  {
        return shops?.first?.objectId ?? CRUDObjectInvalidId
    }
    
    var canView: Bool {
        switch role {
        case .Unknown, .Invite :
            return false
        default:
            return true
        }
    }

    enum Role: Int, CustomDebugStringConvertible {
        case Unknown
        case Owner, Moderator, Member, Invite
        
        var debugDescription: String {
            let displayString: String
            switch self {
            case Unknown:
                displayString = "Unknown"
            case Owner:
                displayString = "Owner"
            case Moderator:
                displayString = "Moderator"
            case Member:
                displayString = "Member"
            case Invite:
                displayString = "Invitee"
            }
            return "<Role:\(displayString)>"
        }
    }
    

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
        communityDescription <- map["description"]
        role <- (map["role"], EnumTransform())
        avatar <- (map["avatar"], AmazonURLTransform())
        isPrivate <- map["isPrivate"]
        members <- map["members"]
        location <- map["location"]
        shops <- map["shops.data"]
        membersCount <- map["members.count"]
        postsCount <- map["posts.count"]
        eventsCount <- map["events.count"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/community"
    }

    static func communityEndpoint(communityId: CRUDObjectId) -> String {
        return (Community.endpoint() as NSString).stringByAppendingPathComponent("\(communityId)")
    }

    
    static func userCommunitiesEndpoint(userId: CRUDObjectId) -> String {
        return (UserProfile.endpoint() as NSString).stringByAppendingPathComponent("\(userId)/communities")
    }
    
    static func membersEndpoint(communityId: CRUDObjectId) -> String {
        return (Community.communityEndpoint(communityId) as NSString).stringByAppendingPathComponent("/members")
        
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}