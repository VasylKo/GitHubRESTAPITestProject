//
//  DonorInfo.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/5/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

enum DonorStatus: Int, CustomStringConvertible  {
    case Undefined = 0
    case Agreed
    case Declined
    
    // CustomStringConvertible
    var description: String {
        switch self {
        case .Undefined:
            return "Undefined"
        case .Agreed:
            return "Agreed"
        case .Declined:
            return "Declined"
    
        }

    }
}

struct DonorInfo: CRUDObject {

    var objectId : CRUDObjectId = CRUDObjectInvalidId
    var bloodGroup: BloodGroup?
    var dueDate: NSDate?
    var declineReason: String?
    var donorStatus: DonorStatus?
    
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
        objectId        <- (map["userId"], CRUDObjectIdTransform())
        bloodGroup      <-  map["bloodGroup"]
        dueDate       <- (map["dueDate"], APIDateTransform())
        declineReason   <-  map["declineReason"]
        donorStatus   <-  map["donorStatus"]
    }
    
    //MARK: Endpoints
    
    static func endpoint() -> String {
        return "/v1.0/donors/me"
    }

    
    //MARK: CustomStringConvertible protocol
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}