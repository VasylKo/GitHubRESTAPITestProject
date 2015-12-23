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
import Box

@objc(LocationSelectorViewController)
class LocationSelectorViewController: UIViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor?
    
    var coordinate: CLLocationCoordinate2D? {
        if  let rowDescriptor = self.rowDescriptor,
            let location: Box<Location> = rowDescriptor.value as? Box<Location> {
                return location.value.coordinates
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
        if let position = self.coordinate {
            marker.position = position
        }
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.draggable = true
        marker.map = self.mapView
        return marker
        }()
    
    private func updateTitle() {
        if  let rowDescriptor = self.rowDescriptor,
            let location: Box<Location> = rowDescriptor.value as? Box<Location> {
                self.title = location.value.name
        }
    }
}

extension LocationSelectorViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
        
        locationController().reverseGeocodeCoordinate(location.coordinate).onSuccess(callback: { location in
            self.rowDescriptor?.value = Box(location)
        })
        
        selectionMarker.position = coordinate
        
        self.updateTitle()
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
            if let box: Box<Location> = valueData as? Box {
                return box.value.name
            }
        }
        return nil
    }
}