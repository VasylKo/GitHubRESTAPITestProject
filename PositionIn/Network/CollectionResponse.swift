//
//  CollectionResponse.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct CollectionResponse<C: CRUDObject>: Mappable {
    private(set) var items: [C]!
    
    init?(_ map: Map) {
        mapping(map)
        switch (items) {
        case (.Some):
            break
        default:
            println("Error while parsing object \(self)")
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        items <- map["data"]
    }

    var description: String {
        return "<\(self.dynamicType):\(items)>"
    }
}
