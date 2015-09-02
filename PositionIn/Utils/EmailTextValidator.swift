//
//  EmailTextValidator.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 8/26/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

//TODO: refactor 

let  kValidationErrorCodeEmail = 603

struct EmailTextValidator {
    static func validate(#string: String) -> NSError? {
        let emailRegex: String = "[^\\s@<>]+@[^\\s@<>]+\\.[^\\s@<>]+"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailTest.evaluateWithObject(string) {
            return NSError(domain: kTextValidationErrorDomain, code: kValidationErrorCodePassword, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Please enter valid email", comment: "")])
        }
        return nil
    }
}