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
import BrightFutures
import Box

protocol BrowseMapViewControllerDelegate: class {
    func browseMapViewControllerCenterMapOnLocation(location: Location)
}

final class BrowseMapViewController: UIViewController, BrowseActionProducer, BrowseModeDisplay, UpdateFilterProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let coordinate = filter.coordinates {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 12))
            self.shouldReverseGeocodeCoordinate = false
            self.mapMovementEnd( CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
    }
    
    var shouldApplySectionFilter = true
    var shouldReverseGeocodeCoordinate = false
    
    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou
    
    let visibleItemTypes: [FeedItem.ItemType] = [.Event, .Promotion, .Item]
    
    var filter = SearchFilter.currentFilter
    
    weak var actionConsumer: BrowseActionConsumer?
    weak var delegate: BrowseMapViewControllerDelegate?
    
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
        for m in markers {
            m.map = nil
        }
        markers = items.filter { self.visibleItemTypes.contains($0.type) }.map { item in
            let marker = GMSMarker()
            marker.position = item.location?.coordinates ?? kCLLocationCoordinate2DInvalid
            marker.map = self.mapView
            marker.icon = markerIcon(item)
            marker.userData = Box(item)
            return marker
        }
        actionConsumer?.browseControllerDidChangeContent(self)
    }
    
    func applyFilterUpdate(update: SearchFilterUpdate) {
        filter = update(filter)
    }
    
    private var markers = [GMSMarker]()
}


extension BrowseMapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if let coordinate = position?.target {
            NSObject.cancelPreviousPerformRequestsWithTarget(self)
            self.performSelector("mapMovementEnd:",
                withObject: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
                afterDelay: 0.5)
            
        }
    }
    
    @objc func mapMovementEnd(location: CLLocation) {
        
        let coordinate = location.coordinate
        
        if (shouldReverseGeocodeCoordinate) {
            locationController().reverseGeocodeCoordinate(coordinate).onSuccess(callback: {[weak self] location in
                SearchFilter.shouldPostUpdateNotification = false
                SearchFilter.setLocation(location)
                self?.delegate?.browseMapViewControllerCenterMapOnLocation(location)
                })
        }
        
        shouldReverseGeocodeCoordinate = true
        
        var f = filter
        f.coordinates = coordinate
        let request: Future<CollectionResponse<FeedItem>,NSError>
        switch browseMode {
        case .ForYou:
            request = api().forYou(f, page: APIService.Page())
        case .New:
            request = api().getFeed(f, page: APIService.Page())
        }
        request.onSuccess {
            [weak self] response in
            Log.debug?.value(response.items)
            if let strongSelf = self
                where isSameCoordinates(
                    //TODO: set valid epsilon
                    strongSelf.mapView.camera.target, coord2: coordinate, epsilon: 0.3) {
                        strongSelf.displayFeedItems(response.items)
            } else {
                Log.debug?.message("Skip map response :\(response.items)")
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        guard let box = marker.userData as? Box<FeedItem> else {
            return false
        }
        let feedItem = box.value
        actionConsumer?.browseController(self, didSelectItem: feedItem.objectId, type: feedItem.type, data:feedItem.itemData)
        return true
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        self.shouldReverseGeocodeCoordinate = false
        SearchFilter.setLocation(nil)
        return true
    }
}