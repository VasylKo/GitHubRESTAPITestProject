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
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 4))
            self.shouldReverseGeocodeCoordinate = false
            self.mapMovementEnd( CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        self.setupUI()
    }
    
    func setupUI() {
        if (UIScreen.mainScreen().bounds.size.width == 375) { //check if iphone 6
            self.bannerButton.setBackgroundImage(UIImage(named: "pledge_banner_iphone6"), forState: .Normal)
        }
        if homeItem == .GiveBlood {
            self.bannerButton.hidden = false
            self.mapViewContainerBottomMargin.constant = 60
        }
        else {
            self.bannerButton.hidden = true
            self.mapViewContainerBottomMargin.constant = 0
        }
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Send analytic info
        if let itemType = filter.itemTypes?.first where filter.itemTypes?.count == 1 {
            trackScreenToAnalytics(AnalyticsLabels.labelForItemType(itemType, suffix: "Map"))
        } else {
            trackScreenToAnalytics(AnalyticsLabels.mapScreen)
        }
     }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var frame = self.mapView.frame
        frame.size.height = (homeItem == .GiveBlood) ? CGRectGetMinY(self.bannerButton.frame) : self.mapView.frame.size.height
        self.mapView.frame = frame
    }
    
    var shouldApplySectionFilter = true
    var shouldReverseGeocodeCoordinate = false
    
    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou
    
    let visibleItemTypes: [FeedItem.ItemType] = [.Project, .Emergency, .Training, .News, .Event, .Market, .GiveBlood, .BomaHotels, .Post]
    
    var filter = SearchFilter.currentFilter
    
    var homeItem: HomeItem?
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
        self.mapViewContainer.addSubViewOnEntireSize(map)
        map.delegate = self
        self.view.bringSubviewToFront(self.bannerButton)
        return map
    }()
    
    
    private func displayFeedItems(items: [FeedItem]) {
        func  markerIcon(item: FeedItem) -> UIImage? {
            switch item.type {
            case .Project:
                return UIImage(named: "ProductMarker")
            case .Emergency:
                return UIImage(named: "PromotionMarker")
            case .Training:
                return UIImage(named: "EventMarker")
            case .Market:
                return UIImage(named: "MarketMarker")
            case .News, .Post:
                return UIImage(named: "news_map")
            case .Event:
                return UIImage(named: "event_map")
            case .GiveBlood:
                return UIImage(named: "category_blood_map")
            case .BomaHotels:
                return UIImage(named: "bomahotel_map")
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
    
    @IBAction func bannerTapped(sender: AnyObject) {
        let url: NSURL? = NSURL(string: "http://www.pledge25kenya.org/")
        if let url = url {
            OpenApplication.Safari(with: url)
        }
    }
    
    @IBOutlet weak var mapViewContainerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var bannerButton: UIButton!
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
        
        //MARK: should refactor
        var homeItem = HomeItem.Unknown
        if let homeItemUnwrapped = self.homeItem {
            homeItem = homeItemUnwrapped
        }
        
        let request: Future<CollectionResponse<FeedItem>,NSError> = api().getAll(homeItem,
            seachFilter: self.filter)

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