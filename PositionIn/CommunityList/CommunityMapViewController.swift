//
//  CommunityMapViewController.swift
//  PositionIn
//
//  Created by ng on 2/24/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import GoogleMaps
import CleanroomLogger
import BrightFutures
import Box

class CommunityMapViewController : UIViewController, GMSMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.animateToZoom(2)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        api().getCommunities(APIService.Page()).onSuccess { [weak self] response in
            if let strongSelf = self {
                strongSelf.displayCommunities(response.items)
            }
        }
    }
    
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
    
    
    func displayCommunities(communities: [Community]) {
        for community in communities {
            let  position = community.location?.coordinates ?? kCLLocationCoordinate2DInvalid
            print(position)
            print(community.name)
            let marker = GMSMarker(position: position)
            marker.title = "Hello World"
            marker.map = self.mapView
        }
        
//        let  position = CLLocationCoordinate2DMake(10, 10)
//        let marker = GMSMarker(position: position)
//        marker.title = "Hello World"
//        marker.map = self.mapView
//        markers = communities.map() { community in
//            let marker = GMSMarker()
//            marker.position = community.location?.coordinates ?? kCLLocationCoordinate2DInvalid
//            marker.map = self.mapView
//            marker.icon = UIImage(named: "EventMarker")
//            marker.userData = Box(community)
//            return marker
//        }
        Log.error?.message("\(markers)")
    }
    
    private var markers = [GMSMarker]()
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        guard let box = marker.userData as? Box<FeedItem> else {
            return false
        }
        let feedItem = box.value

        return true
    }
}