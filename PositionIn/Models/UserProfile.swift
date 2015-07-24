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
    private(set) var objectId: CRUDObjectId
    var firstName: NSString?
    var middleName: NSString?
    var lastName: NSString?
    var location: Location?
    
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
        firstName <- map["firstName"]
        middleName <- map["middleName"]
        lastName <- map["lastName"]
        location <- map["location"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/user"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
    
}