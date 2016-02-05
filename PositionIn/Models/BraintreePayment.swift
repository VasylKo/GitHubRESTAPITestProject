//
//  BraintreePayment.swift
//  PositionIn
//
//  Created by Max Stoliar on 1/10/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import CleanroomLogger

struct BraintreePayment{
    private static let prefix = "/v1.0/payments/braintree/"

    let payment_method_nonce:String
    let amount:String
    
    static func tokenEndpoint() -> String {
        return "\(prefix)client_token"
    }
    
    static func checkoutEndpoint() -> String {
        return "\(prefix)donation/checkout"
    }
    
    static func membershipCheckoutEndpoint() -> String {
        return "\(prefix)membership/checkout"
    }
    
    static func productCheckoutEndpoint() -> String {
        return "\(prefix)product/checkout"
    }
    
    static func tokenMapping() -> (AnyObject? -> String?) {
        return { response in
            if let json = response as? NSDictionary {
                if let token = json["clientToken"] as? String{
                    return token
                } else {
                    Log.error?.message("Got unexpected response")
                    Log.debug?.value(json)
                    return nil
                }
            }
            else {
                Log.error?.message("Got unexpected response: \(response)")
                return nil
            }
            
        }
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