//
//  LocationSelectorViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import GoogleMaps
import XLForm
import CleanroomLogger

@objc(LocationSelectorViewController)
class LocationSelectorViewController: UIViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor?
        
    var coordinate: CLLocationCoordinate2D? {
        if  let rowDescriptor = self.rowDescriptor,
            let location = rowDescriptor.value as? CLLocation where CLLocationCoordinate2DIsValid(location.coordinate) {
             return location.coordinate
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let coordinate = self.coordinate {
            Log.debug?.value(coordinate)
            mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 12)
            self.mapView(mapView, didTapAtCoordinate: coordinate)
        } else {
            Log.error?.message("Initial coordinate did not set")
        }
    }

    private lazy var mapView : GMSMapView = { [unowned self] in
        let map = GMSMapView(frame: self.view.bounds)
        map.delegate = self
        map.settings.compassButton = true
        map.settings.indoorPicker = false
        map.settings.tiltGestures = false
        map.myLocationEnabled = false
        map.mapType = kGMSTypeTerrain
        self.view.addSubViewOnEntireSize(map)
        return map
        }()
    
    private lazy var selectionMarker: GMSMarker = { [unowned self] in
        let marker = GMSMarker()
        self.coordinate.map { marker.position = $0 }
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.draggable = true
        marker.map = self.mapView
        return marker
        }()
    
    private func updateTitle() {
        if let coordinate = self.coordinate {
            self.title = String(format: "%0.4f, %0.4f", coordinate.latitude, coordinate.longitude)
        }
    }
}

extension LocationSelectorViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
        self.rowDescriptor?.value = location
        selectionMarker.position = coordinate
        updateTitle()
    }

}


class CLLocationValueTrasformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            let location = valueData as! CLLocation
            return String(format: "%0.4f, %0.4f", location.coordinate.latitude, location.coordinate.longitude)
        }
        return nil
    }
    
}