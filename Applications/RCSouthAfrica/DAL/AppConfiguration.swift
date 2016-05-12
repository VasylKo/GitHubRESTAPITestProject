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
            imageBaseURL = NSURL(string: "https://krcs.rc-app.com/")!
            xmppHostname = "chat-krcs.rc-app.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyA3NvrDKBcpIsnq4-ZACG41y7Mj-wSfVrY"
            newRelicToken = "AA0492dd667078eb6a7d0a70ba7267487f6b3fff21"
        case .Staging:
            baseURL = NSURL(string: "https://app-za-sta.positionin.com/api/")!
            imageBaseURL = NSURL(string: "https://app-za-sta.positionin.com/")!
            xmppHostname = "chat-sta.positionin.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
            newRelicToken = "AA0492dd667078eb6a7d0a70ba7267487f6b3fff21"
        case .StagingCopy:
            baseURL = NSURL(string: "https://app-za-sta2.positionin.com/api/")!
            imageBaseURL = NSURL(string: "https://app-za-sta2.positionin.com/")!
            xmppHostname = "chat-sta2.positionin.com"
            googleAnalystLogLevel = GAILogLevel.Verbose
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
            newRelicToken = "AA0492dd667078eb6a7d0a70ba7267487f6b3fff21"
        case .Dev:
            baseURL = NSURL(string: "https://app-za-dev.positionin.com/api/")!
            imageBaseURL = NSURL(string: "https://app-za-dev.positionin.com/")!
            xmppHostname = "chat-dev.positionin.com"
            googleAnalystLogLevel = GAILogLevel.None
            googleMapsKey = "AIzaSyDkUHOpFWNBDAW5Gu2I0E7iHe4FRWGyM6o"
            newRelicToken = "AA0492dd667078eb6a7d0a70ba7267487f6b3fff21"
        }
        xmppPort = 5222
    }
    
    let googleAnalystLogLevel: GAILogLevel
    
    let baseURL : NSURL
    let imageBaseURL : NSURL
    
    let googleMapsKey: String
    
    let newRelicToken: String
    
    let xmppHostname: String
    let xmppPort: Int
    
    private enum Environment: String {
        case Dev
        case Staging
        case StagingCopy
        case Prod
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
    
    let countryFullName = "South Africa"
    let appShortTitle = "SARCS"
    let appFullTitle = "South Africa Red Cross Society"
    let currencySymbol = "R"
    lazy var currencyFormatter: NSNumberFormatter = {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.currencySymbol = "\(AppConfiguration().currencySymbol) "
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.roundingMode = .RoundDown
        return currencyFormatter
        }()

    var appVersion: String? {
        return (NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as? String).map {"\($0)"}
    }
}
