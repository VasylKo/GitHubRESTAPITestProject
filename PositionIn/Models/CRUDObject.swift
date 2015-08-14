//
//  CRUDObject.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

//TODO: refactor CRUDObjectId
typealias CRUDObjectId = String
let CRUDObjectInvalidId: CRUDObjectId = ""

let CRUDObjectIdTransform = TransformOf<CRUDObjectId, String>(fromJSON: { (jsonValue: String?) -> CRUDObjectId? in
        return jsonValue ?? CRUDObjectInvalidId
    }, toJSON: { value in
        if let jsonValue = value where jsonValue !=  CRUDObjectInvalidId{
            return jsonValue
        }
        return nil
})

protocol CRUDObject: Mappable, Printable {
    

    var objectId: CRUDObjectId { get }
    
    static func endpoint() -> String    
}