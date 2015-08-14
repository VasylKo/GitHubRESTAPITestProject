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

struct Location: Mappable, Printable {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var coordinates: CLLocationCoordinate2D!
    var street1: String?
    var street2: String?
    var country: String?
    var state: String?
    var city: String?
    var zip: String?
    
    
    init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
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


final class LocationCoordinateTransform: TransformType {
    typealias Object = CLLocationCoordinate2D
    typealias JSON = [Double]
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> CLLocationCoordinate2D? {
        if let array = value as? JSON where count(array) == 2 {
            return CLLocationCoordinate2D(latitude: array.first!, longitude: array.last!)
        }
        return nil
    }
    
    func transformToJSON(value: CLLocationCoordinate2D?) -> [Double]? {
        if let coord = value {
            return [coord.latitude, coord.longitude]
        }
        return nil
    }
}