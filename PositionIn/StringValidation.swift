//
//  StringValidation.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 02/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

//TODO: StringValidation: update validation rules
//TODO: StringValidation: remove copy/paste
//TODO: StringValidation: add validation operators
//TODO: StringValidation: Use NSRegularExpression

struct StringValidation {
    //Returns a error if strings is not pass validation
    typealias Validator = (String) -> NSError?
    
    func sequence(s: [Validator]) -> Validator {
        return { string in
            return s.reduce(nil) { (e: NSError?, validator: Validator) -> NSError? in
                return e ?? validator(string)
            }
        }
    }
    
    func required() -> Validator {
        return length(min: 1)
    }
    
    func any() -> Validator {
        return { _ in
            return nil
        }
    }

    
    func length(min: Int = 0, max: Int = Int.max) -> Validator {
        return { string in
            if contains(min..<max, count(string)) {
                return nil
            }
            return StringValidation.error(
                ErrorCode.TextLength.rawValue,
                localizedDescription: NSLocalizedString("This field should have ", comment: "Length validation")
            )
        }
    }
    
    func name() -> Validator {
        return { string in
            let nameRegex: String = "^[\\p{L}\\s'.-]+$"
            let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
            if !nameTest.evaluateWithObject(string) {
                StringValidation.error(
                    ErrorCode.Password.rawValue,
                    localizedDescription: NSLocalizedString("Please enter a valid name", comment: "Name validation")
                )
            }
            return nil
        }
    }
    
    func password() -> Validator {
        return { string in
            let passwordRegex: String = "^[a-zA-Z0-9]*$"
            let passwordTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            if !passwordTest.evaluateWithObject(string) {
                return StringValidation.error(
                    ErrorCode.Password.rawValue,
                    localizedDescription: NSLocalizedString("Please enter a valid password", comment: "Password validation")
                )
            }
            return nil
        }
    }
    
    func email() -> Validator {
        return { string in
            let emailRegex: String = "[^\\s@<>]+@[^\\s@<>]+\\.[^\\s@<>]+"
            let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            if !emailTest.evaluateWithObject(string) {
                return StringValidation.error(
                    ErrorCode.Email.rawValue,
                    localizedDescription: NSLocalizedString("Please enter a valid email", comment: "Email validation")
                )
            }
            return nil
        }
    }
    
    static func error(code: Int, localizedDescription: String) -> NSError {
        return error(code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
    
    static func error(code: Int, userInfo:[NSObject : AnyObject]? = nil) -> NSError {
        return NSError(domain: kTextValidationErrorDomain, code: code, userInfo: userInfo)
    }
    
    static let errorDomain = "com.bekitzur.stringValidation"
    
    enum ErrorCode: Int {
        case TextLength
        case Email
        case Password
        case Username
    }
    
}