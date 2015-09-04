//
//  ObjectInfo.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import CleanroomLogger
import ObjectMapper

struct ObjectInfo: Mappable, Printable {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var title: String?

    
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
        title <- map["name"]
    }
    
    
    var description: String {
        return "<\(self.dynamicType):\(objectId),>"
    }
    
}
