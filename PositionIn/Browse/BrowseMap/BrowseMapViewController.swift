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
        if let coordinate = filter.coordinates {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 12))
        }
    }
    
    let visibleItemTypes: [FeedItem.ItemType] = [.Event, .Promotion, .Item]
    
    var filter = SearchFilter.currentFilter
    
    weak var actionConsumer: BrowseActionConsumer?
    
    lazy private var mapView: GMSMapView = { [unowned self] in
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
        func  markerIcon(item: FeedItem) -> UIImage? {
            switch item.type {
            case .Event:
                return UIImage(named: "EventMarker")
            case .Promotion:
                return UIImage(named: "PromotionMarker")
            case .Item:
                return UIImage(named: "ProductMarker")
            default:
                return nil
            }
        }
        markers.map { $0.map = nil }
        markers = items.filter { contains(self.visibleItemTypes, $0.type) }.map {
            item in
            let marker = GMSMarker()
            marker.position = item.location?.coordinates ?? kCLLocationCoordinate2DInvalid
            marker.map = self.mapView
            marker.icon = markerIcon(item)
            marker.userData = Box(item)
            return marker
        }
        actionConsumer?.browseControllerDidChangeContent(self)
    }
    
    private var markers = [GMSMarker]()
    
}


extension BrowseMapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if let coordinate = position?.target {
            var f = filter
            f.coordinates = coordinate
            api().getFeed(f, page: APIService.Page()).onSuccess {
                [weak self] response in
                Log.debug?.value(response.items)
                if let strongSelf = self
                   where isSameCoordinates(
                    //TODO: set valid epsilon
                    strongSelf.mapView.camera.target, position.target, epsilon: 0.3) {
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
            actionConsumer?.browseController(self, didSelectItem: feedItem.objectId, type: feedItem.type, data:feedItem.itemData)
        
        }
        
        return true
    }
}