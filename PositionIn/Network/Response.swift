//
//  CollectionResponse.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct CollectionResponse<C: CRUDObject>: Mappable {
    private(set) var items: [C]!
    private(set) var total: Int!
    
    init?(_ map: Map) {
        mapping(map)
        switch (items, total) {
        case (.Some, .Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        items <- map["data"]
        total <- map["count"]
    }

    var description: String {
        return "<\(self.dynamicType)-(\(total)):\(items)>"
    }
}

struct UpdateResponse: Mappable{
    private(set) var objectId: CRUDObjectId = CRUDObjectInvalidId
    
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

    }
    
    var description: String {
        return "<\(self.dynamicType)-(\(objectId))>"
    }

}
