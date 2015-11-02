//
//  Location.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import CleanroomLogger
import ObjectMapper
import CoreLocation

let LocationObjectInvalidId: CRUDObjectId = "LocationObjectInvalidId"

struct Location: Mappable, CustomStringConvertible {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var coordinates: CLLocationCoordinate2D!
    var street1: String?
    var street2: String?
    var country: String?
    var state: String?
    var city: String?
    var zip: String?
    
    //Used for geocoding
    var name: String?
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
    }
    
    init?(_ map: Map) {
        mapping(map)
//        if objectId == CRUDObjectInvalidId {
//            Log.error?.message("Error while parsing object")
//            Log.debug?.trace()
//            Log.verbose?.value(self)
//            return nil
//        }
        switch (coordinates) {
        case (.Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    static var currentLocation: Location {
        get {
            var location = Location(objectId:LocationObjectInvalidId)
            location.name = NSLocalizedString("Current Location", comment: "Current Location")
            return location
        }
    }
    
    func isCurrentLocation() -> Bool {
        return self.objectId == LocationObjectInvalidId
    }
    
    mutating func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        street1 <- map["street1"]
        street2 <- map["street2"]
        country <- map["country"]
        state <- map["state"]
        city <- map["city"]
        zip <- map["zip"]
        coordinates <- (map["coordinates"], LocationCoordinateTransform())
    }
    
    var description: String {
        return "<\(self.dynamicType):\(coordinates.latitude),\(coordinates.longitude)>"
    }
}