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
        switch membershipPlanId {
        case CRUDObjectId(1):
            return "membership_student_card_bg"
        case CRUDObjectId(2):
            return "membership_over18_card_bg"
        case CRUDObjectId(3):
            return "membership_ordinary_card_bg"
        case CRUDObjectId(4):
            return "membership_life_card_bg"
        case CRUDObjectId(5):
            return "corporate_card_bg"
        case CRUDObjectId(6):
            return "corporate_bronze_card_bg"
        case CRUDObjectId(7):
            return "corporate_silver_card_bg"
        case CRUDObjectId(8):
            return "corporate_gold_card_bg"
        default:
            return ""
        }
    }
    
    var membershipPlanId : CRUDObjectId = CRUDObjectInvalidId
    
    var startDate : NSDate?
    var endDate : NSDate?
    
    var active : Bool?

    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        membershipCardId <-  map["cardId"]
        membershipPlanId <- map["membershipPlanId"]
        startDate <- (map["startDate"], APIDateTransform())
        endDate <- (map["endDate"], APIDateTransform())
    }
    
}