//
//  EplusMembershipDetails.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct EplusMembershipDetails : Mappable {
    
    // FIXME: Ambulance Hot fix - need to remove
    init() {}
    
    var membershipCardId : String?
    var membershipCardImageName : String {
        
        switch (membershipPlanId, status) {
            
        case (CRUDObjectId(1), .Expired):
            return "eplus_family_expired_card_bg"
        case (CRUDObjectId(1), _):
            return "eplus_family_card_bg"
            
        case (CRUDObjectId(2), .Expired):
            return "eplus_individual_expired_card_bg"
        case (CRUDObjectId(2), _):
            return "eplus_individual_card_bg"
            
        case (CRUDObjectId(3), .Expired):
            return "eplus_school_expired_card_bg"
        case (CRUDObjectId(3), _):
            return "eplus_school_card_bg"
            
        case (CRUDObjectId(4), .Expired):
            return "eplus_corporate_expired_card_bg"
        case (CRUDObjectId(4), _):
            return "eplus_corporate_card_bg"

        case (CRUDObjectId(5), .Expired):
            return "eplus_residential_expired_card_bg"
        case (CRUDObjectId(5), _):
            return "eplus_residential_card_bg"
            
        case (CRUDObjectId(6), .Expired):
            return "eplus_saccos_expired_card_bg"
        case (CRUDObjectId(6), _):
            return "eplus_saccos_card_bg"
            
        default:
            return ""
        }
    }
    
    var membershipPlanId : CRUDObjectId = CRUDObjectInvalidId
    
    var startDate : NSDate?
    var endDate : NSDate?
    
    var active : Bool?
    
    enum MembershipDetailsStatus : Int {
        case Unknown          = -1
        case Active           = 0
        case isAboutToExpired = 1
        case Expired          = 2
    }
    var status : MembershipDetailsStatus = .Unknown
    var daysLeft : Int?

    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        membershipCardId <-  map["cardId"]
        membershipPlanId <- map["membershipPlanId"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
        status <- map["status"]
        daysLeft <- map["daysLeft"]
    }
    
}