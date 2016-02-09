//
//  CardItem.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Box

enum CardItem: Int {
    case MPesa, PayPal, CreditDebitCard
    
    static var count = (CreditDebitCard.rawValue + 1)
    
    static func cardName(item: CardItem) -> String? {
        switch item {
        case .MPesa:
            return "M-Pesa"
        case .PayPal:
            return "PayPal"
        case .CreditDebitCard:
            return "Credit/Debit Card"
        }
    }
    
    static func cardDescription(item: CardItem) -> String? {
        switch item {
        case .MPesa:
            return "Enter payment details and complete your purchase"
        case .PayPal:
            return "Enter payment details and complete your purchase"
        case .CreditDebitCard:
            return "Visa, Mastercard, American Express"
        }
    }
    
    static func cardImage(item: CardItem) -> UIImage? {
        switch item {
        case .MPesa:
            return UIImage(named: "mpesa")
        case .PayPal:
            return UIImage(named: "paypal")
        case .CreditDebitCard:
            return UIImage(named: "creditcard")
        }
    }
    
    static func cardPayment(item: CardItem) -> String? {
        switch item {
        case .MPesa:
            return "Mpesa"
        case .PayPal:
            return "Braintree"
        case .CreditDebitCard:
            return "Braintree"
        }
    }
}

class CardItemValueTrasformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            if let box: Box<CardItem> = valueData as? Box {
                return CardItem.cardName(box.value)
            }
        }
        return nil
    }
}
