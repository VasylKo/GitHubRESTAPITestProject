//
//  VolunteerMapViewController.swift
//  PositionIn
//
//  Created by ng on 3/4/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import GoogleMaps
import CleanroomLogger
import BrightFutures
import Box

class VolunteerMapViewController : UIViewController, GMSMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.animateToZoom(2)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Log.error?.value(self.mapView)
//        api().getCommunities(APIService.Page()).onSuccess { [weak self] response in
//            if let strongSelf = self {
//                strongSelf.displayCommunities(response.items)
//            }
//        }
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
            let marker = GMSMarker(position: position)
            marker.map = self.mapView
            marker.icon = UIImage(named: "PromotionMarker")
            marker.userData = Box(community)
        }
    }
    
    private var markers = [GMSMarker]()
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        guard let box = marker.userData as? Box<FeedItem> else {
            return false
        }
        let community = box.value
        
        return true
    }
    
    func initializeMapViewController () -> UIViewController {
        return VolunteerMapViewController()
    }
}