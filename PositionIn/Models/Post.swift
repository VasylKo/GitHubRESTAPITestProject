//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct Post: CRUDObject {
    private(set) var objectId: CRUDObjectId
    
    init?(_ map: Map) {
        mapping(map)
        switch (objectId) {
        case (.Some):
            break
        default:
            println("Error while parsing object \(self)")
            return nil
        }
    }

    mutating func mapping(map: Map) {
        objectId <- map["id"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/post"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}