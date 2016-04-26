//
//  EPlusServicen.swift
//  PositionIn
//
//  Created by ng on 1/28/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

enum TextLinkType {
    case PhoneNumber, Email, Url
}

struct TextLink {
    var title: String
    var type: TextLinkType
}

struct EPlusService: CRUDObject {
    
    // FIXME: Ambulance Hot fix - need to remove
    init() {}
    
    var objectId : CRUDObjectId = CRUDObjectInvalidId
    var name : String?
    var shortDesc: String?
    var serviceDesc: String?
    var infoBlocks: [InfoGroup]?
    var footnote: String?
    var textLinks: [TextLink]?
    
    var serviceImageName: String {
        switch objectId {
        case CRUDObjectId(0):
            return "service_1_eplus_icon"
        case CRUDObjectId(1):
            return "service_2_eplus_icon"
        case CRUDObjectId(2):
            return "service_3_eplus_icon"
        case CRUDObjectId(3):
            return "service_5_eplus_icon"
        default:
            return ""
        }
    }
    
    var mainImageName: String {
        switch objectId {
        case CRUDObjectId(0):
            return "eplus_about_2"
        case CRUDObjectId(1):
            return "eplus_about_3"
        case CRUDObjectId(2):
            return "eplus_about_4"
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
