//
//  PhotoInfo.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import CleanroomLogger
import ObjectMapper

struct PhotoInfo: Mappable, Printable {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var url: String?
    
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
        url <- map["url"]
    }
    
    
    var description: String {
        return "<\(self.dynamicType):\(objectId),>"
    }

}

