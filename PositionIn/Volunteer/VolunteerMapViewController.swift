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
    
    private lazy var userVolunteers : [Community] = []
    private lazy var volunteers : [Community] = []
    private var markers = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.animateToZoom(2)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.volunteerMap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        api().currentUserId().flatMap { userId in
            return api().getUserVolunteers(userId)
            }.flatMap { [weak self] (response: CollectionResponse<Community>) -> Future<CollectionResponse<Community>, NSError> in
                self?.userVolunteers = response.items
                return api().getVolunteers()
            }.onSuccess { [weak self] (response: CollectionResponse<Community>) -> Void in
                if let strongSelf = self {
                    strongSelf.volunteers = response.items
                    strongSelf.displayVolunteers()
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
    
    
    func displayVolunteers() {
        let allVolunteers = self.volunteers + self.userVolunteers
        for volunteer in allVolunteers {
            if let position = volunteer.location?.coordinates {
                let marker = GMSMarker(position: position)
                marker.map = self.mapView
                marker.icon = UIImage(named: "PromotionMarker")
                marker.userData = Box(volunteer)
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        guard let box = marker.userData as? Box<Community> else {
            return false
        }
        
        let volunteer = box.value
        
        trackEventToAnalytics("Main", action: "Click", label: "Community")
        let controller = Storyboards.Main.instantiateVolunteerDetailsViewControllerId()
        controller.volunteer = volunteer
        controller.author = volunteer.owner
        controller.type = .Volunteer
        let notTojoin = self.userVolunteers.contains { volunteerInVolunteers in
            return volunteerInVolunteers.objectId == volunteer.objectId
        }
        controller.joinAction = !notTojoin
        navigationController?.pushViewController(controller, animated: true)
        
        return true
    }
}