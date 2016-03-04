//
//  Order.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 03/03/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

enum PaymentMethod: Int, CustomStringConvertible {
    case Unknown = 0, Braintree, MPESA
    
    var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .Braintree:
            return "Braintree"
        case .MPESA:
            return "MPESA"
        }
    }
}

enum OrderStatus: Int {
    case Unknown = 0, New, Reserve, ProcessingPayment, PaymentReceived, Shipped, Delivered
}

final class Order: FeedItem {
    var entityDetails: Product?
    var paymentDate: NSDate?
    var paymentMethod: PaymentMethod?
    var quantity: String?
    var status: OrderStatus?
    var transactionId: String?
    
    override func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        entityDetails <- map["entityDetails"]
        paymentDate <- (map["paymentDate"], APIDateTransform())
        paymentMethod <- map["paymentMethod"]
        price <- map["price"]
        quantity <- map["quantity"]
        status <- map["status"]
        transactionId <- map["transactionId"]
    }
    
    required init?(_ map: Map) {
        super.init(map)
        type = .Wallet
    }
}