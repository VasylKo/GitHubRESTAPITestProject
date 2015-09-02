//
//  NameTextValidator.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 8/26/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

//TODO: refactor 

let  kTextValidationErrorDomain = "com.bekitzur.textValidator"
let  kValidationErrorCodeName = 601

struct NameTextValidator {
    static func validate(#string: String) -> NSError? {
        let nameRegex: String = "^[\\p{L}\\s'.-]+$"
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !nameTest.evaluateWithObject(string) {
            return NSError(domain: kTextValidationErrorDomain, code: kValidationErrorCodeName, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Please enter valid name", comment: "")])
        }
        return nil
    }
}
