//
//  ObjectInfo.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import CleanroomLogger
import ObjectMapper

class ObjectInfo: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var title: String?

    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
    }
    
    
    required init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        title <- map["name"]
    }
    
    static func endpoint() -> String {
        return ""
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId),>"
    }
    
}


class UserInfo: ObjectInfo {
    var isCommunity: Bool = false
    var avatar: NSURL?
    var role : Int = 0
    
    override func mapping(map: Map) {
        super.mapping(map)
        avatar <- (map["avatar"], AmazonURLTransform())
        isCommunity <- map["isCommunity"]
        role <- map["role"]
    }
    
}