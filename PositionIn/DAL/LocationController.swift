//
//  LocationController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures

final class LocationController {
    
    
    
    init() {
        locationProvider = LocationProvider(requirements: .WhenInUse)
    }
    
    private let locationProvider: LocationProvider

}
