//
//  SearchItem.swift
//  PositionIn
//
//  Created by mpol on 10/5/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

import ObjectMapper
import CleanroomLogger

struct SearchItem: CRUDObject {
    
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    
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
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
    
    enum SearchItemType: Int, Printable {
        case Unknown
        case Category
        case Product
        case Event
        case Promotion
        case Community
        case People
        
        var description: String {
            switch self {
            case .Unknown:
                return "Unknown/All"
            case .Category:
                return "Category"
            case .Product:
                return "Product"
            case .Event:
                return "Event"
            case .Promotion:
                return "Emergency"
            case Community:
                return "Community"
            case People:
                return "People"
            }
        }
    }
    
    static func endpoint() -> String {
        return "/v1.0/feed"
    }
}