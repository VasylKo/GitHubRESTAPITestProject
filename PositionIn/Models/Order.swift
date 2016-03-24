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

enum OrderStatus: Int, CustomStringConvertible {
    case Unknown = 0, New, Reserve, ProcessingPayment, PaymentReceived, Shipped, Delivered
    
    var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .New:
            return "New"
        case .Reserve:
            return "Reserve"
        case .ProcessingPayment:
            return "Processing Payment"
        case .PaymentReceived:
            return "Payment Received"
        case .Shipped:
            return "Shipped"
        case .Delivered:
            return "Delivered"
        }
    }
}

final class Order: FeedItem {
    var entityDetails: Product?
    var paymentDate: NSDate?
    var paymentMethod: PaymentMethod?
    var quantity: Int?
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
        
        determinateOrderType()
    }
    
    /*
    Logic to determinate what type of wallet entity.
    We need it to show different placeholder image for each wallet entity.
    It could be: .Market, .Emergency, .Project, .Donation
    Look backend API to see orderTypeNumber values. Donation type don't have orderTypeNumber.
    */
    private func determinateOrderType() {
        guard let entityDetails = entityDetails, orderTypeNumber = entityDetails.typeNumber, orderType = FeedItem.ItemType(rawValue: orderTypeNumber) else {
            type = .Donation
            return
        }
        
        type = orderType
    }
    
    required init?(_ map: Map) {
        super.init(map)
        
    }
}