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
            baseURL = NSURL(string: "https://krcs.rc-app.com/api/")!
//            amazonURL = NSURL(string: "https://pos-prod.s3.amazonaws.com/")!
            //Workaround bug in S3
            amazonURL = NSURL(string: "https://krcs.rc-app.com")!
            xmppHostname = "krcs.rc-app.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyA3NvrDKBcpIsnq4-ZACG41y7Mj-wSfVrY"
        case .Staging:
            baseURL = NSURL(string: "https://app-sta.positionin.com/api/")!
            amazonURL = NSURL(string: "https://pos-sta.s3.amazonaws.com/")!
            xmppHostname = "app-sta.positionin.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
        case .StagingCopy:
            baseURL = NSURL(string: "https://app-sta2.positionin.com/api/")!
            amazonURL = NSURL(string: "https://pos-sta.s3.amazonaws.com/")!
            xmppHostname = "app-sta2.positionin.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
        case .Dev:
            baseURL = NSURL(string: "https://app-dev.positionin.com/api/")!
            amazonURL = NSURL(string: "https://pos-dev.s3.amazonaws.com/")!
            xmppHostname = "app-dev.positionin.com"
            googleAnalystLogLevel = GAILogLevel.None
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
        }
        xmppPort = 5222
    }
    
    let googleAnalystLogLevel: GAILogLevel
    
    let baseURL : NSURL
    let amazonURL : NSURL
    
    let googleMapsKey: String
    
    let xmppHostname: String
    let xmppPort: Int
    
    private enum Environment: String {
        case Dev = "Dev"
        case Staging = "Staging"
        case StagingCopy = "StagingCopy"
        case Prod = "Production"
    }
    
    private static var environment: Environment {
        #if PROD_ENV
            return .Prod
        #elseif STAGING_ENV
            return .Staging
        #elseif STAGING_COPY_ENV
            return .StagingCopy
        #else
            return .Dev
        #endif
    }
    
    let currencyFormatter: NSNumberFormatter = {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.currencySymbol = "KES "
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.roundingMode = .RoundDown
        return currencyFormatter
        }()

    var appVersion: String? {
        let env = AppConfiguration.environment.rawValue
        return (NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as? String).map {"\($0)-\(env)"}
    }
}
