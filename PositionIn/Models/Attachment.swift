//
//  Attachment.swift
//  PositionIn
//
//  Created by ng on 2/11/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Attachment : Mappable {
    
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name : String?
    var type : String?
    var url : NSURL?
    
    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        objectId <-  map["id"]
        name <- map["name"]
        type <- map["type"]
        url <- (map["url"], AmazonURLTransform())
    }
    
}