//
//  CRUDObject.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

typealias CRUDObjectId = String!

protocol CRUDObject: Mappable {
    
    

    var objectId: CRUDObjectId { get }
    
    static func endpoint() -> String
}