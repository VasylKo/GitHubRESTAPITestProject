//
//  CLLocationCoordinate2D+Equal.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 10/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import CoreLocation

func isSameCoordinates(coord1: CLLocationCoordinate2D, coord2:CLLocationCoordinate2D, epsilon: CLLocationDegrees = 0) -> Bool {
    return fabs(coord1.latitude - coord2.latitude) <= epsilon && fabs(coord1.longitude - coord2.longitude) <= epsilon
}