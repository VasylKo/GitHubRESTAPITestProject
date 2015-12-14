//
//  HomeItem.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 27/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation

enum HomeItem: Int, CustomDebugStringConvertible {
    case Unknown = 0
    case Projects, Emergency, Training, Ambulance, GiveBlood, News, Membership, Donate, Events, Market, BomaHotels, Volunteer
    
    static var count: Int {
        return Volunteer.rawValue
    }
    
    
    static func homeItemForUI(value: Int) -> HomeItem {
        switch value {
        case 0:
            return .Emergency
        case 1:
            return .Ambulance
        case 2:
            return .GiveBlood
        case 3:
            return .News
        case 4:
            return .Membership
        case 5:
            return .Donate
        case 6:
            return .Training
        case 7:
            return .Events
        case 8:
            return .Projects
        case 9:
            return .Market
        case 10:
            return .BomaHotels
        case 11:
            return .Volunteer
        default:
            return .Unknown
        }
    }
    
    func endpoint(objectId: String) -> String? {
        if let endpoint = self.endpoint() {
            return "\(endpoint)\(objectId)"
        }
        
        return nil
    }
    
    func endpoint() -> String? {
        switch self {
        case .Emergency:
            return "/v1.0/emergency/"
        case .Ambulance:
            return "/v1.0/ambulance/"
        case .GiveBlood:
            return "/v1.0/giveBlood/"
        case .News:
            return "/v1.0/news/"
        case .Membership:
            return "/v1.0/membership/"
        case .Donate:
            return "/v1.0/donate/"
        case .Training:
            return "/v1.0/training/"
        case .Events:
            return "/v1.0/events/"
        case .Projects:
            return "/v1.0/projects/"
        case .Market:
            return "/v1.0/market/"
        case .BomaHotels:
            return "/v1.0/bomaHotels/"
        case .Volunteer:
            return "/v1.0/volunteer/"
        case .Unknown:
            fallthrough
        default:
            return nil
        }
    }
    
    func displayString() -> String {
        switch self {
        case .Emergency:
            return NSLocalizedString("Emergency", comment: "HomeItem")
        case .Ambulance:
            return NSLocalizedString("Ambulance", comment: "HomeItem")
        case .GiveBlood:
            return NSLocalizedString("Blood", comment: "HomeItem")
        case .News:
            return NSLocalizedString("News", comment: "HomeItem")
        case .Membership:
            return NSLocalizedString("Membership", comment: "HomeItem")
        case .Donate:
            return NSLocalizedString("Donate", comment: "HomeItem")
        case .Training:
            return NSLocalizedString("Training", comment: "HomeItem")
        case .Events:
            return NSLocalizedString("Events", comment: "HomeItem")
        case .Projects:
            return NSLocalizedString("Projects", comment: "HomeItem")
        case .Market:
            return NSLocalizedString("Market", comment: "HomeItem")
        case .BomaHotels:
            return NSLocalizedString("Boma Hotels", comment: "HomeItem")
        case .Volunteer:
            return NSLocalizedString("Volunteer", comment: "HomeItem")
        case .Unknown:
            fallthrough
        default:
            return NSLocalizedString("All", comment: "HomeItem")
        }
    }
    
    func endpoint() -> String? {
        switch self {
        case .Emergency:
//            return "/v1.0/
            return FeedItem.getAllEndpoint()
        case .GiveBlood:
            return "/v1.0/giveBlood/"
        case .News:
            return "/v1.0/post/"
        case .Training:
            return FeedItem.getAllEndpoint()
        case .Events:
            return "/v1.0/events/"
        case .Projects:
            return FeedItem.getAllEndpoint()
        case .Market:
            return "/v1.0/products/"
        case .BomaHotels:
            return "/v1.0/bomaHotels/"
        case .Volunteer:
            return "/v1.0/community/"
        case .Unknown:
            fallthrough
        default:
            return nil
        }
    }
    
    func endpoint(objectId: CRUDObjectId) -> String? {
        if let enpoint = self.endpoint() {
            return "\(enpoint)\(objectId)"
        } else {
            return nil
        }
    }
    
    
    func image() -> UIImage? {
        switch self {
        case .Emergency:
            return UIImage(named: "home_emergencies")
        case .Ambulance:
            return UIImage(named: "home_ambulance")
        case .GiveBlood:
            return UIImage(named: "home_blood")
        case .News:
            return UIImage(named: "home_news")
        case .Membership:
            return UIImage(named: "home_membership")
        case .Donate:
            return UIImage(named: "home_donate")
        case .Training:
            return UIImage(named: "home_training")
        case .Events:
            return UIImage(named: "home_event")
        case .Projects:
            return UIImage(named: "home_projects")
        case .Market:
            return UIImage(named: "home_market")
        case .BomaHotels:
            return UIImage(named: "home_hotel")
        case .Volunteer:
            return UIImage(named: "home_volunteer")
        case .Unknown:
            fallthrough
        default:
            return nil
        }
    }
    
    var debugDescription: String {
        return "<HomeItem:\(displayString)>"
    }
}
