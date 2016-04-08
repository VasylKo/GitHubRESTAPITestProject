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
    
    private lazy var userCommunities : [Community] = []
    private lazy var communities : [Community] = []
    private var markers = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.animateToZoom(2)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.communitiesMap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        api().currentUserId().flatMap { userId in
            return api().getUserCommunities(userId)
            }.flatMap { [weak self] (response: CollectionResponse<Community>) -> Future<CollectionResponse<Community>, NSError> in
                self?.userCommunities = response.items
                return api().getCommunities(APIService.Page())
            }.onSuccess { [weak self] (response: CollectionResponse<Community>) -> Void in
                if let strongSelf = self {
                    strongSelf.communities = response.items
                    strongSelf.displayCommunities()
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
    
    
    func displayCommunities() {
        let allCommunities = self.communities + self.userCommunities
        for community in allCommunities {
            if let position = community.location?.coordinates {
                let marker = GMSMarker(position: position)
                marker.map = self.mapView
                marker.icon = UIImage(named: "PromotionMarker")
                marker.userData = Box(community)
            }
        }
    }
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        guard let box = marker.userData as? Box<Community> else {
            return false
        }
        
        let community = box.value
       
        trackGoogleAnalyticsEvent("Main", action: "Click", label: "Community")
        let controller = Storyboards.Main.instantiateVolunteerDetailsViewControllerId()
        controller.volunteer = community
        controller.author = community.owner
        controller.type = .Community
        let notTojoin = self.userCommunities.contains { communityInCommunities in
            return communityInCommunities.objectId == community.objectId
        }
        controller.joinAction = !notTojoin
        navigationController?.pushViewController(controller, animated: true)

        return true
    }
}