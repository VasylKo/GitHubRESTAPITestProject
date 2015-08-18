//
//  LocationController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import GoogleMaps

final class LocationController {
    
    func getCurrentLocation() {
        
    }
    
    init() {
        locationProvider = LocationProvider(requirements: .WhenInUse)
    }
    
    private let locationProvider: LocationProvider

}

func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) -> Future<Location, NSError> {
    let promise = Promise<Location, NSError>()
    let geocoder = GMSGeocoder()
    GMSGeocoder().reverseGeocodeCoordinate(coordinate) { response, error in
        if let error = error {
            promise.failure(error)
        } else if let address = response?.firstResult() {
            var location = Location()
            location.coordinates = address.coordinate
            location.country = address.country
            location.zip = address.postalCode
            location.city = address.locality
            location.state = address.administrativeArea
            location.street1 = address.thoroughfare
            promise.success(location)
        }
    }
    return promise.future
}

