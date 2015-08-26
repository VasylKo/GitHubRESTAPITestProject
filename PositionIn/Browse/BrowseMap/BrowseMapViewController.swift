//
//  MapViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import GoogleMaps

final class BrowseMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        locationController().getCurrentCoordinate().onSuccess { [weak self] coordinate in
            self?.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 12))
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    lazy private var mapView: GMSMapView = {
        let map = GMSMapView(frame: self.view.bounds)
        map.mapType = kGMSTypeTerrain
        map.settings.tiltGestures = false
        map.settings.rotateGestures = false
        map.settings.myLocationButton = true
        map.settings.indoorPicker = false
        map.myLocationEnabled = true
        self.view.addSubViewOnEntireSize(map)
        return map
    }()
    
}
