//
//  Comment.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger


struct Comment: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var text: String?
    var date: NSDate?
    var author: UserInfo?
    
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
        date <- (map["date"], APIDateTransform())
        author <- map["author"]
    }
    
    static func endpoint() -> String {
        return ""
    }

    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}