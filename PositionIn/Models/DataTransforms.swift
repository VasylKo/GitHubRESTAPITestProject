//
//  DataTransforms.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper
import PosInCore
import CoreLocation

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

final class APIDateTransform: DateFormatterTransform {
    
    init() {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        super.init(dateFormatter: formatter)
    }
    
}

class ImageURLTransform: RelativeURLTransform {
    init() {
        super.init(baseURL: AppConfiguration().imageBaseURL)
    }
}


final class LocationCoordinateTransform: TransformType {
    typealias Object = CLLocationCoordinate2D
    typealias JSON = [Double]
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> CLLocationCoordinate2D? {
        if let array = value as? JSON where array.count == 2 {
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