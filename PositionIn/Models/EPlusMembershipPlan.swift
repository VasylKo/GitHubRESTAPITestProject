//
//  EplusMembershipPlan.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/18/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct EPlusPlanOption: Mappable {
    var price: Int?
    var minParticipants: Int?
    var maxParticipants: Int?
    var costDescription: String?
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        price            <-  map["price"]
        minParticipants  <-  map["from"]
        maxParticipants  <-  map["to"]
        costDescription  <-  map["comments"]
    }
}

enum EPlusPlanType : Int, CustomStringConvertible {
    case Unknown = 29, Family, Individual, Schools, Corporate, ResidentialEstates, Sacco
    
    var description: String {
        return ""
    }
}

struct EPlusMembershipPlan: CRUDObject {
    // FIXME: Ambulance Hot fix - need to remove
    init() {}
    
    var objectId : CRUDObjectId = CRUDObjectInvalidId
    var name : String?
    var planOptions: [EPlusPlanOption]?
    var otherBenefits: [String]?
    var benefitGroups: [InfoGroup]?
    var price: Int?
    var planParameters: EPlusPlanParameters?
    
    var type: EPlusPlanType {
        return EPlusPlanType(rawValue: Int(objectId) ?? EPlusPlanType.Unknown.rawValue)!
    }
    
    var featured: Bool?
    var durationDays: Int?
    
    var shortName: String? {
        if type == .Schools {
            return NSLocalizedString("School")
        }
        return name
    }
    
    var costDescription: String {
        let formatedPrice = String("\(AppConfiguration().currencySymbol) \(price ?? 0)")
        
        switch type {
        case .Family:
            return "\(formatedPrice) Annually"
        case .Individual:
            return "\(formatedPrice) Annually"
        case .Schools:
            return "\(formatedPrice) Annually (per child)"
        case .Corporate:
            return "Annual Membership Rate"
        case .ResidentialEstates:
            return "\(formatedPrice) Annually (per household)"
        case .Sacco:
            return "\(formatedPrice) Annually (per member)"
        default:
            return ""
        }
    }
    
    var membershipImageName: String {
        switch type {
        case .Family:
            return "family_plan_eplus_icon"
        case .Individual:
            return "individual_plan_eplus_icon"
        case .Schools:
            return "school_plan_eplus_icon"
        case .Corporate:
            return "corporate_plan_eplus_icon"
        case .ResidentialEstates:
            return "residential_plan_eplus_icon"
        case .Sacco:
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
        objectId       <- (map["id"], CRUDObjectIdTransform())
        price          <-  map["price"]
        
        
        //type           <-  map["objectId"]
        
        
        name           <-  map["name"]
        featured       <-  map["featured"]
        durationDays   <-  map["durationDays"]
        planOptions    <-  map["benefits.prices"]
        benefitGroups  <-  map["benefits.groups"]
        otherBenefits  <-  map["benefits.items"]
    }
    
    //MARK: Endpoints
    
    static func endpoint() -> String {
        return "/v1.0/ambulance/memberships"
    }
    
    static func endpoint(identifier : CRUDObjectId) -> String {
        return "/v1.0/ambulance/membership/" + identifier
    }
    
    //MARK: CustomStringConvertible protocol
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}
