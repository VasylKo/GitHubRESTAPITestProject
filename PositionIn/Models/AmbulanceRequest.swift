//
//  AmbulanceRequest.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 04/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//



import ObjectMapper
import CleanroomLogger

struct AmbulanceRequest: CRUDObject {
    
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var text: String?
    var photos: [PhotoInfo]?
    var location: Location?
    var incidentType: String?
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
    }
    
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
        text <- map["text"]
        photos <- map["photos"]
        location <- map["location"]
        incidentType <- map["incidentType"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/ambulanceRequests"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}
