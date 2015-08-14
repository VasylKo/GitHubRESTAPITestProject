//
//  UserProfile.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct UserProfile: CRUDObject {
    private(set) var objectId: CRUDObjectId = CRUDObjectInvalidId
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var userDescription: String?
//    "gender": <gender enum>
//    "dob": <date>,
    var phone: String?
    var avatar: String?
    var backgroundImage: String?
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
        objectId <- (map["id"], CRUDObjectIdTransform)
        firstName <- map["firstName"]
        middleName <- map["middleName"]
        lastName <- map["lastName"]
        userDescription <- map["description"]
        phone <- map["phone"]
        avatar <- map["avatar"]
        backgroundImage <- map["background"]
        location <- map["location"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/users"
    }
    
    static func myProfileEndpoint() -> String {
        return "/v1.0/me"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
    
}