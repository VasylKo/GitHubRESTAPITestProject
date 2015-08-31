//
//  PasswordTextValidator.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 8/26/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

let  kValidationErrorCodePassword = 602

struct PasswordTextValidator {
    static func validate(#string: String) -> NSError? {
        let passwordRegex: String = "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{6,32}) "
        let passwordTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if !passwordTest.evaluateWithObject(string) {
            return NSError(domain: kTextValidationErrorDomain, code: kValidationErrorCodePassword, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Please enter valid password", comment: "")])
        }
        return nil
    }
}