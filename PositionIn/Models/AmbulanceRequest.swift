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
    var descriptionString: String?
    var photos: [PhotoInfo]?
    var location: Location?
    var incidentType: NSNumber?
    var accidentDescription: String?
    
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
        descriptionString <- map["description"]
        photos <- map["photos"]
        location <- map["location"]
        incidentType <- map["type"]
        accidentDescription <- map["accidentDescription"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/ambulance/"
    }
    
    static func endpoint(id: String) -> String {
        return "\(self.endpoint())\(id)"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}
