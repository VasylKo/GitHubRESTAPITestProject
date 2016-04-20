//
//  EplusMembershipDetails.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct EPlusPlanOptions : Mappable {
    var id : String?
    var companyName : String?
    var dependentsCount : Int?
    var estateName : String?
    var houseCount : Int?
    var houseHoldersCount : Int?
    var peopleCount : Int?
    var saccoName : String?
    var saccoPeopleCount : Int?
    var schoolName : String?
    var studentsCount : Int?
    
    init() {}
    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        id <-  map["id"]
        companyName <-  map["companyName"]
        dependentsCount <-  map["dependentsCount"]
        estateName <-  map["estateName"]
        houseCount <-  map["houseCount"]
        houseHoldersCount <-  map["houseHoldersCount"]
        peopleCount <-  map["peopleCount"]
        saccoName <-  map["saccoName"]
        saccoPeopleCount <-  map["saccoPeopleCount"]
        schoolName <-  map["schoolName"]
        studentsCount <-  map["studentsCount"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/ambulance/membership/order"
    }
}

struct EplusMembershipDetails : CRUDObject {
    var objectId : CRUDObjectId = CRUDObjectInvalidId
    
    // FIXME: Ambulance Hot fix - need to remove
    init() {}
    
    var membershipCardId : String?
    var membershipCardImageName : String {
        
        switch (membershipPlanId, status) {
            
        case (CRUDObjectId(EPlusPlanType.Family.rawValue), .Expired):
            return "eplus_family_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.Family.rawValue), _):
            return "eplus_family_card_bg"
            
        case (CRUDObjectId(EPlusPlanType.Individual.rawValue), .Expired):
            return "eplus_individual_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.Individual.rawValue), _):
            return "eplus_individual_card_bg"
            
        case (CRUDObjectId(EPlusPlanType.Schools.rawValue), .Expired):
            return "eplus_school_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.Schools.rawValue), _):
            return "eplus_school_card_bg"
            
        case (CRUDObjectId(EPlusPlanType.Corporate.rawValue), .Expired):
            return "eplus_corporate_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.Corporate.rawValue), _):
            return "eplus_corporate_card_bg"

        case (CRUDObjectId(EPlusPlanType.ResidentialEstates.rawValue), .Expired):
            return "eplus_residential_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.ResidentialEstates.rawValue), _):
            return "eplus_residential_card_bg"
            
        case (CRUDObjectId(EPlusPlanType.Sacco.rawValue), .Expired):
            return "eplus_saccos_expired_card_bg"
        case (CRUDObjectId(EPlusPlanType.Sacco.rawValue), _):
            return "eplus_saccos_card_bg"
            
        default:
            return ""
        }
    }
    
    var membershipPlanId : CRUDObjectId = CRUDObjectInvalidId
    var membershipPlanName : String?
    
    var startDate : NSDate?
    var endDate : NSDate?
    
    var active : Bool?
    
    enum MembershipDetailsStatus : Int {
        case Unknown          = -1
        case Active           = 0
        case isAboutToExpired = 1
        case Expired          = 2
        case Ordered          = 3
    }
    var status : MembershipDetailsStatus = .Unknown
    var daysLeft : Int?

    var planOptions : EPlusPlanOptions?
    
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
        active <- map["active"]
        planOptions <- map["details"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/ambulance/membership/active"
    }
    
    //MARK: CustomStringConvertible protocol
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}