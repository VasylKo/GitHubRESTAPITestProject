//
//  HomeItem.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 27/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation

enum HomeItem: Int, CustomDebugStringConvertible {
    case Unknown = -1
    case Emergency, Ambulance, GiveBlood, News, Membership, Donate, Training, Events, Projects, Market, BomaHotels, Volunteer
    
    static var count: Int {
        return (HomeItem.Volunteer.rawValue + 1)
    }
    
    func valueForRequest() -> NSNumber {
        switch self {
        case .Emergency:
            return 2
        case .Ambulance:
            return self.rawValue
        case .GiveBlood:
            return self.rawValue
        case .News:
            return self.rawValue
        case .Membership:
            return self.rawValue
        case .Donate:
            return self.rawValue
        case .Training:
            return 3
        case .Events:
            return self.rawValue
        case .Projects:
            return 1
        case .Market:
            return self.rawValue
        case .BomaHotels:
            return self.rawValue
        case .Volunteer:
            return self.rawValue
        case .Unknown:
            fallthrough
        default:
            return 0
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
            return NSLocalizedString("Project", comment: "HomeItem")
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
