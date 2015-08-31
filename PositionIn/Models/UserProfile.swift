//
//  UserProfile.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

final class UserProfile: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var userDescription: String?
//    "gender": <gender enum>
//    "dob": <date>,
    var phone: String?
    var avatar: NSURL?
    var backgroundImage: NSURL?
    var location: Location?
    var guest: Bool =  false
        
    enum Gender {
        case Unknown
        case Male
        case Female
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
    
    init() {
        
    }
    
    func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        firstName <- map["firstName"]
        middleName <- map["middleName"]
        lastName <- map["lastName"]
        userDescription <- map["description"]
        phone <- map["phone"]
        avatar <- (map["avatar"], AmazonURLTransform())
        backgroundImage <- (map["background"], AmazonURLTransform())
        location <- map["location"]
        guest <- map["guest"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/users"
    }
    
    static func myProfileEndpoint() -> String {
        return "/v1.0/me"
    }
    
    static func userEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent("\(userId)")
    }

    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
 
    static let CurrentUserDidChangeNotification = "CurrentUserDidChangeNotification"
}