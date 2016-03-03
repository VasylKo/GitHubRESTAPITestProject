//
//  Donation.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 03/03/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Donation: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var entityDetails: Product?
    var paymentDate: NSDate?
    var paymentMethod: String? // FIXME: Need to change to enum value
    var price: Float?
    var transactionId: String?
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
    }
    
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
        objectId <- (map["id"], CRUDObjectIdTransform())
        entityDetails <- map["entityDetails"]
        paymentDate <- (map["paymentDate"], APIDateTransform())
        paymentMethod <- map["paymentMethod"]
        price <- map["price"]
        transactionId <- map["transactionId"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/payments/donations"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}