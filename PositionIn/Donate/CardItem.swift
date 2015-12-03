//
//  CardItem.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

enum CardItem: Int {
    case Unknown, MPesa, Airtel, OrangeMonde, PayPal, CreditDebitCard
    
    static var count = (CreditDebitCard.rawValue + 1)
    
    static func cardName(item: CardItem) -> String? {
        switch item {
        case .Unknown:
            return nil
        case .MPesa:
            return "M-Pesa"
        case .Airtel:
            return "Airtel"
        case .OrangeMonde:
            return "Orange Money"
        case .PayPal:
            return "PayPal"
        case .CreditDebitCard:
            return "Credit/Debit Card"
        }
    }
    
    
    static func cardImage(item: CardItem) -> UIImage? {
        switch item {
        case .Unknown:
            return nil
        case .MPesa:
            return UIImage(named: "mpesa")
        case .Airtel:
            return UIImage(named: "airtel")
        case .OrangeMonde:
            return UIImage(named: "orange_money")
        case .PayPal:
            return UIImage(named: "paypal")
        case .CreditDebitCard:
            return UIImage(named: "creditcard")
        }
    }
}
