//
//  OpenApplication.swift
//  PositionIn
//
//  Created by ng on 1/22/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import MapKit

public class OpenApplication: NSObject {
    
    class func appleMap(with destination : CLLocationCoordinate2D) {
        let urlString = "http://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)"
        let url = NSURL(string: urlString)!
        UIApplication.sharedApplication().openURL(url)
    }

}
