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
    
    //TODO: remove from protocol
    static func endpoint() -> String
}