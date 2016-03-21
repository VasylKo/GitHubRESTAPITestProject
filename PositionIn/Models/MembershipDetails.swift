//
//  MembershipDetails.swift
//  PositionIn
//
//  Created by ng on 2/2/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct MembershipDetails : Mappable {
    
    var membershipCardId : String?
    var membershipCardImageName : String {
        
        switch (membershipPlanId, status) {
        case (CRUDObjectId(1), _):
            return "membership_student_card_bg"
        case (CRUDObjectId(1), .Expired):
            return "membership_student_expired_card_bg"
            
        case (CRUDObjectId(2), _):
            return "membership_over18_card_bg"
        case (CRUDObjectId(2), .Expired):
            return "membership_over18_expired_card_bg"
            
        case (CRUDObjectId(3), _):
            return "membership_ordinary_card_bg"
        case (CRUDObjectId(3), .Expired):
            return "membership_ordinary_expired_card_bg"
            
        case (CRUDObjectId(4), _):
            return "membership_life_card_bg"
        case (CRUDObjectId(4), .Expired):
            return "membership_life_expired_card_bg"
            
        case (CRUDObjectId(5), _):
            return "corporate_card_bg"
        case (CRUDObjectId(5), .Expired):
            return "corporate_expired_card_bg"
            
        case (CRUDObjectId(6), _):
            return "corporate_bronze_card_bg"
        case (CRUDObjectId(6), .Expired):
            return "corporate_expired_card_bg"
            
        case (CRUDObjectId(7), _):
            return "corporate_silver_card_bg"
        case (CRUDObjectId(7), .Expired):
            return "corporate_expired_card_bg"
            
        case (CRUDObjectId(8), _):
            return "corporate_gold_card_bg"
        case (CRUDObjectId(8), .Expired):
            return "corporate_expired_card_bg"
            
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