//
//  CRUDObject.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

typealias CRUDObjectId = String
let CRUDObjectInvalidId: CRUDObjectId = ""


protocol CRUDObject: Mappable, Printable {
    

    var objectId: CRUDObjectId { get  set}
    
    static func endpoint() -> String    
}

final class CRUDObjectIdTransform: TransformType {
    typealias Object = CRUDObjectId
    typealias JSON = String
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> CRUDObjectId? {
        return (value as? Object) ?? CRUDObjectInvalidId
    }
    
    func transformToJSON(value: CRUDObjectId?) -> String? {
        if let jsonValue = value where jsonValue !=  CRUDObjectInvalidId {
            return jsonValue
        }
        return nil
    }
}