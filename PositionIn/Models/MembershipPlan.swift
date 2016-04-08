//
//  MembershipPlan.swift
//  PositionIn
//
//  Created by ng on 1/28/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct MembershipPlan: CRUDObject {
    
    enum PlanType : Int, CustomStringConvertible {
        case Unknown    = 0
        case Individual = 1
        case Corporate  = 2
        
        var description: String {
            switch self {
            case .Individual:
                return "Individual"
            case .Corporate:
                return "Corporate"
            default:
                return "Unknown"
            }
        }
    }
    
    var objectId : CRUDObjectId = CRUDObjectInvalidId
    var name : String?
    var benefits : [String]?
    var price : Int?
    var type : PlanType = .Unknown
    var featured : Bool?
    var durationDays : Int?
    var lifetime : Bool?
    var membershipImageName : String {
        switch objectId {
        case CRUDObjectId(1):
            return "dont_rename_ic_school"
        case CRUDObjectId(2):
            return "dont_rename_ic_user18"
        case CRUDObjectId(3):
            return "dont_rename_ic_user"
        case CRUDObjectId(4):
            return "dont_rename_ic_lifetime"
        case CRUDObjectId(5):
            return "dont_rename_ic_corporate"
        case CRUDObjectId(6):
            return "dont_rename_ic_bronze"
        case CRUDObjectId(7):
            return "dont_rename_ic_silver"
        case CRUDObjectId(8):
            return "dont_rename_ic_gold"
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
        objectId     <- (map["id"], CRUDObjectIdTransform())
        name         <-  map["name"]
        benefits     <-  map["benefits"]
        price        <-  map["price"]
        type         <-  (map["type"], EnumTransform())
        featured     <-  map["featured"]
        durationDays <-  map["durationDays"]
        lifetime     <-  map["lifetime"]
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
