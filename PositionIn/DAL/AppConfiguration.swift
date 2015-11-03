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
        switch AppConfiguration.environment {
        case .Prod:
            baseURL = NSURL(string: "https://app.positionin.com/api/")!
//            amazonURL = NSURL(string: "https://pos-prod.s3.amazonaws.com/")!
            //Workaround bug in S3
            amazonURL = NSURL(string: "https://app.positionin.com")!
            xmppHostname = "app.positionin.com"
        case .Staging:
            baseURL = NSURL(string: "https://app-sta.positionin.com/api/")!
            amazonURL = NSURL(string: "https://pos-sta.s3.amazonaws.com/")!
            xmppHostname = "app-sta.positionin.com"
        case .Dev:
            baseURL = NSURL(string: "https://app-dev.positionin.com/api/")!
            amazonURL = NSURL(string: "https://pos-dev.s3.amazonaws.com/")!
            xmppHostname = "app-dev.positionin.com"
        }
        
        currencySymbol = "$"
        googleMapsKey = "AIzaSyA3NvrDKBcpIsnq4-ZACG41y7Mj-wSfVrY"
        xmppPort = 5222
    }
    
    let baseURL : NSURL
    let amazonURL : NSURL
    
    let currencySymbol: String
    
    let googleMapsKey: String
    
    let xmppHostname: String
    let xmppPort: Int
    
    private enum Environment: String {
        case Dev = "Dev"
        case Staging = "Staging"
        case Prod = "Production"
    }
    
    private static var environment: Environment {
        #if PROD_ENV
            return .Prod
        #elseif STAGING_ENV
            return .Staging
        #else
            return .Dev
        #endif
    }

    var appVersion: String? {
        let env = AppConfiguration.environment.rawValue
        return map(NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey] as? String) {"\($0)-\(env)"}
    }
}
