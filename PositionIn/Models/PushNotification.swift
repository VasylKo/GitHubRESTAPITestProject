//
//  PushNotification.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 07/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct PushNotification: CRUDObject {
    
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        objectId <-  map["notificationId"]
    }
    
    //TODO: remove from protocol
    static func endpoint() -> String {
        return ""
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}
