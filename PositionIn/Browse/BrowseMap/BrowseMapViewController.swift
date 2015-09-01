//
//  MapViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import GoogleMaps
import CleanroomLogger
import Box

final class BrowseMapViewController: UIViewController, BrowseActionProducer {

    override func viewDidLoad() {
        super.viewDidLoad()
        locationController().getCurrentCoordinate().onSuccess { [weak self] coordinate in
            self?.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 12))
        }
        

    }
    
    var filter = SearchFilter.currentFilter
    
    weak var actionConsumer: BrowseActionConsumer?
    
    lazy private var mapView: GMSMapView = {
        let map = GMSMapView(frame: self.view.bounds)
        map.mapType = kGMSTypeTerrain
        map.settings.tiltGestures = false
        map.settings.rotateGestures = false
        map.settings.myLocationButton = true
        map.settings.indoorPicker = false
        map.myLocationEnabled = true
        self.view.addSubViewOnEntireSize(map)
        map.delegate = self
        return map
    }()
    
    
    private func displayFeedItems(items: [FeedItem]) {
        markers.map { $0.map = nil }
        markers = items.map { item in
            let marker = GMSMarker()
            marker.position = item.location?.coordinates ?? kCLLocationCoordinate2DInvalid
            marker.map = self.mapView
            marker.userData = Box(item)
            return marker
        }
        actionConsumer?.browseControllerDidChangeContent(self)
    }
    
    private var markers = [GMSMarker]()
    
    private func isSameCoordinates(#coord1: CLLocationCoordinate2D, coord2:CLLocationCoordinate2D, epsilon: CLLocationDegrees) -> Bool {
        return fabs(coord1.latitude - coord2.latitude) <= epsilon && fabs(coord1.longitude - coord2.longitude) <= epsilon
    }

}


extension BrowseMapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if let coordinate = position?.target {
            var f = filter
            f.coordinates = coordinate
            api().getFeed(f, page: APIService.Page()).onFailure { error in
                Log.error?.value(error)
            }.onSuccess { [weak self] response in
                Log.debug?.value(response.items)
                if let strongSelf = self
                   where strongSelf.isSameCoordinates(
                    //TODO: set valid epsilon
                    coord1: strongSelf.mapView.camera.target, coord2: position.target, epsilon: 0.3) {
                        strongSelf.displayFeedItems(response.items)
                } else {
                    Log.debug?.message("Skip map response :\(response.items)")
                }
                
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if let box = marker.userData  as? Box<FeedItem> {
            let feedItem = box.value
            actionConsumer?.browseController(self, didSelectItem: feedItem.objectId, type: feedItem.type)
        
        }
        
        return true
    }
}