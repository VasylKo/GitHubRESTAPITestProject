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
        let urlString = "http://maps.apple.com/?saddr=&daddr=\(destination.latitude),\(destination.longitude)"
        let url = NSURL(string: urlString)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    class func Safari(with url : NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
    
    class func Tel(with tel : String) {
        guard let phoneNumberURL = NSURL(string: "tel://" + tel) else { return }
        if UIApplication.sharedApplication().canOpenURL(phoneNumberURL) {
            UIApplication.sharedApplication().openURL(phoneNumberURL)
        }
        
    }
}
