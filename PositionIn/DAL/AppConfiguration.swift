//
//  AppConfiguration.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

final class AppConfiguration {
    init() {
        #if PROD_ENV
        //Prod
        baseURL = NSURL(string: "https://positionin.com/api/")!
        amazonURL = NSURL(string: "https://pos-prod.s3.amazonaws.com/")!
        xmppHostname = "positionin.com"
        #elseif STAGING_ENV
        //Staging
        baseURL = NSURL(string: "https://app-sta.positionin.com/api/")!
        amazonURL = NSURL(string: "https://pos-sta.s3.amazonaws.com/")!
        xmppHostname = "app-sta.positionin.com"
        #else
        //Dev
        baseURL = NSURL(string: "https://app-dev.positionin.com/api/")!
        amazonURL = NSURL(string: "https://pos-dev.s3.amazonaws.com/")!
        xmppHostname = "app-dev.positionin.com"
        #endif
        googleMapsKey = "AIzaSyA3NvrDKBcpIsnq4-ZACG41y7Mj-wSfVrY"
        xmppPort = 5222
    }
    
    let baseURL : NSURL
    let amazonURL : NSURL
    
    let googleMapsKey: String
    
    let xmppHostname: String
    let xmppPort: Int

    var appVersion: String? { 
        return NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey] as? String
    }
}
