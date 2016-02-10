//
//  MPessaPayment.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 08/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import CleanroomLogger

struct MPesaPayment {
    private static let prefix = "/v1.0/payments/mpesa/"
    
    static func donateCheckoutEndpoint() -> String {
        return "\(prefix)donation/checkout"
    }
    
    static func membershipCheckoutEndpoint() -> String {
        return "\(prefix)membership/checkout"
    }
    
    static func productCheckoutEndpoint() -> String {
        return "\(prefix)product/checkout"
    }
    
    static func productCheckoutEndpoint(itemId itemId: String) -> String {
        return "\(prefix)\(itemId)/status"
    }
    
    static func checkoutMapping() -> (AnyObject? -> String?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let success = json["success"] as? Bool {
                    if success {
                        return ""
                    } else {
                        return json["error"] as? String
                    }
                } else {
                    Log.error?.message("Got unexpected response")
                    Log.debug?.value(json)
                    return nil
                }
            }
                //TODO: need handle nil response
            else if response == nil {
                return nil
            }
                
            else {
                Log.error?.message("Got unexpected response: \(response)")
                return nil
            }
        }
    }
}