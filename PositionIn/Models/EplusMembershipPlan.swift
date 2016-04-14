//
//  EplusMembershipPlan.swift
//  PositionIn
//
//  Created by ng on 1/28/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct EplusMembershipPlan: CRUDObject {
    
    enum PlanType : Int, CustomStringConvertible {
        case Unknown = 0, Family, Individual, Schools, Corporate, ResidentialEstates, Sacco
    
        var description: String {
            return ""
        }
    }
    
    // FIXME: Ambulance Hot fix - need to remove
    init() {}
    
    
    var objectId : CRUDObjectId = CRUDObjectInvalidId
    var name : String?
    var costDescription : String?
    var planDescription : String?
    var thisCovers : [String]?
    var benefits : [String]?
    var otherBenefits : [String]?
    var price : Int?
    var type : PlanType = .Unknown
    var durationDays : Int?
    var membershipImageName : String {
        switch objectId {
        case CRUDObjectId(PlanType.Family.rawValue):
            return "family_plan_eplus_icon"
        case CRUDObjectId(PlanType.Individual.rawValue):
            return "individual_plan_eplus_icon"
        case CRUDObjectId(PlanType.Schools.rawValue):
            return "school_plan_eplus_icon"
        case CRUDObjectId(PlanType.Corporate.rawValue):
            return "corporate_plan_eplus_icon"
        case CRUDObjectId(PlanType.ResidentialEstates.rawValue):
            return "residential_plan_eplus_icon"
        case CRUDObjectId(PlanType.Sacco.rawValue):
            return "saccos_plan_eplus_icon"
        default:
            return ""
        }
    }
    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
//        objectId     <- (map["id"], CRUDObjectIdTransform())
//        name         <-  map["name"]
//        benefits     <-  map["benefits"]
//        price        <-  map["price"]
//        type         <-  (map["type"], EnumTransform())
//        featured     <-  map["featured"]
//        durationDays <-  map["durationDays"]
//        lifetime     <-  map["lifetime"]
    }
    
    //MARK: Endpoints
    
    static func endpoint() -> String {
        return "/v1.0/memberships"
    }
    
    static func endpoint(identifier : CRUDObjectId) -> String {
        return self.endpoint() + "/" + identifier
    }
    
    //MARK: CustomStringConvertible protocol
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}
