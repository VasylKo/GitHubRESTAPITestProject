//
//  PaymentManager.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/23/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import BrightFutures

enum PurchaseType {
    case Donation, Membership, Product
}

protocol PurchaseConvertible {
    var price: NSNumber { get }
    var itemId: String? { get }
    var quantity: Int { get }
    var itemName: String { get }
    var purchaseType: PurchaseType { get }
    var paymentTypes: CardItem { get }
}

extension PurchaseConvertible {
    var totalAmount: Float {
        return price.floatValue * Float(quantity)
    }
    
    var totalAmountFofmattedString: String {
        return AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: totalAmount)) ?? ""
    }
}

protocol PaymentSystem {
    init(item: PurchaseConvertible)
    func purchase() -> Future<Void, NSError>
}

protocol PaymentController: class {
    init (paymentSystem: PaymentSystem)
}

struct PaymentSystemProvider {
    static func paymentSystemWithItem(item: PurchaseConvertible) -> PaymentSystem {
        
        switch item.paymentTypes {
        case .CreditDebitCard:
            return BraintreePaymentSystem(item: item)
        case .MPesa:
             return MpesaPaymentSystem(item: item)
        }
    }
}


