//
//  LocationProvider.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import CoreLocation


public class LocationProvider: NSObject {
    public enum LocationRequirements {
        case Always
        case WhenInUse
    }
    
    public enum State {
        case Idle
        case Locating
        case Denied
    }
    
    public var currentCoordinate: CLLocationCoordinate2D? {
        return CLLocationCoordinate2DIsValid(coord) ? coord : nil
    }

    private(set) public var state: State
    public var accuracy: CLLocationAccuracy {
        set {
            dispatch_async(dispatch_get_main_queue()) {
                let isLocating = self.state == .Locating
                if isLocating {
                    self.locationManager.stopUpdatingLocation()
                }
                self.locationManager.desiredAccuracy = newValue
                if isLocating {
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
        get {
            return locationManager.desiredAccuracy
        }
    }
    
    public init(requirements: LocationRequirements = .WhenInUse) {
        self.requirements = requirements
        state = .Idle
        coord = kCLLocationCoordinate2DInvalid
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    
    public func startUpdatingLocation() {
        locationManager.delegate = self
        if requestAuthForStatus(CLLocationManager.authorizationStatus()) {
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            if self.state != .Locating {
                self.locationManager.startUpdatingLocation()
                let prevState = self.state
                self.state = .Locating
                if prevState != .Denied {
                    self.postNotification(LocationProvider.DidStartLocatingNotification)
                }
            }
        }
    }
    
    public func stopUpdatingLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.locationManager.stopUpdatingLocation()
            self.state = .Idle
            self.postNotification(LocationProvider.DidFinishLocatingNotification)
        }
    }
    
    private func locationDeniedByUser() {
        locationManager.stopUpdatingLocation()
        coord = kCLLocationCoordinate2DInvalid
        state = .Denied
        postNotification(LocationProvider.DidUpdateCoordinateNotification)
        postNotification(LocationProvider.DidFinishLocatingNotification)
    }
    
    private func requestAuthForStatus(status: CLAuthorizationStatus) -> Bool {
        
        let (requiredStatus: CLAuthorizationStatus, method: (CLLocationManager)->() -> Void) = {
            switch self.requirements {
            case .Always:
                return (.AuthorizedAlways, CLLocationManager.requestAlwaysAuthorization)
            case .WhenInUse:
                return (.AuthorizedWhenInUse, CLLocationManager.requestWhenInUseAuthorization)
            }
        }()
        if status != requiredStatus {
            method(self.locationManager)()
            return true
        }
        return false
    }
    
    private var coord: CLLocationCoordinate2D
    private let locationManager: CLLocationManager
    private let requirements: LocationRequirements
    
    func postNotification(notificationName: String, info: [NSObject: AnyObject]? = nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self, userInfo: info)
    }
    
    static let DidStartLocatingNotification = "LocationProviderDidStartLocatingNotification"
    static let DidFinishLocatingNotification = "LocationProviderDidFinishLocatingNotification"
    static let DidUpdateCoordinateNotification = "LocationProviderDidUpdateCoordinateNotification"
}


extension LocationProvider: CLLocationManagerDelegate {
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last  as? CLLocation {
            coord = location.coordinate
            self.postNotification(LocationProvider.DidUpdateCoordinateNotification)
        }
    }
    
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if error.code == CLError.Denied.rawValue {
            locationDeniedByUser()
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied:
            locationDeniedByUser()
        case .NotDetermined:
            break
        default:
            startUpdatingLocation()
        }
    }
}