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
    
    
    func getCurrentLocation() -> Future<Location, NSError> {
        return getCurrentCoordinate().flatMap { coordinate in
            return reverseGeocodeCoordinate(coordinate)
        }
    }
    
    func getCurrentCoordinate() -> Future<CLLocationCoordinate2D, NSError> {
        let promise = Promise<CLLocationCoordinate2D, NSError>()
        var future = promise.future
        
        synced(self) {
            if let coordinate = self.lastKnownCoordinate
                where self.lastKnownCoordinateExpirationDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                    future = Future.succeeded(coordinate)
//                    promise.success(coordinate)
            } else {
                future = promise.future
                self.pendingPromises.append(promise)
                self.locationProvider.startUpdatingLocation()                
            }
        }

        return future
    }
    
    init() {
        cacheStorage = NSUserDefaults.standardUserDefaults()
        locationProvider = LocationProvider(requirements: .WhenInUse)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "didUpdateCoordinate:", name: LocationProvider.DidUpdateCoordinateNotification, object: locationProvider)
        notificationCenter.addObserver(self, selector: "didFinishLocating:", name: LocationProvider.DidFinishLocatingNotification, object: locationProvider)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private var pendingPromises: [Promise<CLLocationCoordinate2D, NSError>] = []
    
    private let locationProvider: LocationProvider
    private let cacheStorage: NSUserDefaults
    
    @objc private func didUpdateCoordinate(notification: NSNotification) {
        synced(self) {
            if let coordinate = self.locationProvider.currentCoordinate {
                self.lastKnownCoordinate = coordinate
                self.lastKnownCoordinateExpirationDate = NSDate(timeIntervalSinceNow: self.kCoordinateExpirationThreshold)
                self.pendingPromises.map { $0.success(coordinate) }
                self.pendingPromises = []
            }
            self.locationProvider.stopUpdatingLocation()
        }
    }
    
    @objc private func didFinishLocating(notification: NSNotification) {
        synced(self) {
            let error = NSError(
                domain: LocationController.kLocationControllerErrorDomain,
                code: LocationController.ErrorCodes.CouldNotGetCoordinate.rawValue,
                userInfo: nil
            )
            self.pendingPromises.map { $0.failure(error) }
            self.pendingPromises = []
        }
    }
    
    
    private var lastKnownCoordinateExpirationDate: NSDate {
        set {
            cacheStorage.setObject(newValue, forKey: kLastKnownCoordinateExpirationKey)
        }
        get {
            return (cacheStorage.objectForKey(kLastKnownCoordinateExpirationKey) as? NSDate) ?? (NSDate.distantPast() as! NSDate)
        }
    }
    
    private var lastKnownCoordinate: CLLocationCoordinate2D? {
        get {
            if let data = cacheStorage.objectForKey(kLastKnownCoordinateKey) as? [String : NSNumber],
               let lat = data[kLatitudeKey]?.doubleValue,
               let long = data[kLongitudeKey]?.doubleValue {
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            return nil
        }
        set {
            let data: [String : NSNumber]? = newValue.map { coord in
                let lat: NSNumber  = NSNumber(double: coord.latitude)
                let long: NSNumber  = NSNumber(double: coord.longitude)
                return [
                    kLatitudeKey: lat,
                    kLongitudeKey: long,
                ]
            }
            cacheStorage.setObject(data, forKey: kLastKnownCoordinateKey)
        }
    }

    static let kLocationControllerErrorDomain = "kLocationControllerErrorDomain"
    
    enum ErrorCodes: Int {
        case CouldNotGetCoordinate
    }
    
    private let kCoordinateExpirationThreshold: NSTimeInterval = 60 * 2
    private let kLatitudeKey = "lat"
    private let kLongitudeKey = "long"
    private let kLastKnownCoordinateKey = "kLastKnownCoordinateKey"
    private let kLastKnownCoordinateExpirationKey = "kLastKnownCoordinateExpirationKey"
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

