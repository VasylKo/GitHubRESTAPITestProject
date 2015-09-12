//
//  StringValidation.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 02/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

//TODO: StringValidation: update validation rules
//TODO: StringValidation: remove copy/paste
//TODO: StringValidation: Use NSRegularExpression
//TODO: StringValidation: Wrap in a class with ivar rules

protocol StringValidatable {
    var validationString: String? { get }
}


struct StringValidation {
    //Returns a error if strings is not pass validation
    typealias Validator = (String) -> NSError?
    
    typealias ValidationRule = (field: StringValidatable, validator:StringValidation.Validator)
    
    static func sequence(s: [Validator]) -> Validator {
        return { string in
            return s.reduce(nil) { (e: NSError?, validator: Validator) -> NSError? in
                return e ?? validator(string)
            }
        }
    }
    
    static func required() -> Validator {
        return length(min: 1)
    }
    
    static func any() -> Validator {
        return { _ in
            return nil
        }
    }
    
    static func length(min: Int = 0, max: Int = 100) -> Validator {
        return { string in
            if contains(min..<max, count(string)) {
                return nil
            }
            let description = String(format: NSLocalizedString("This field cannot be less than %ld and longer than %ld ", comment: "Length validation"),
                min,
                max
            )
            return StringValidation.error(
                ErrorCode.TextLength.rawValue,
                localizedDescription: description
            )
        }
    }
    
    static func percentage() -> Validator {
        return length(min: 1, max: 2)
    }

    static func name() -> Validator {
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
    
    static func password() -> Validator {
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
    
    static func email() -> Validator {
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
    
    static func validate(rules: [ValidationRule]) -> (field: StringValidatable, error: NSError)? {
        for rule in rules {
            let string = rule.field.validationString
            switch string {
            case .Some(let validationString):
                if let error = rule.validator(validationString) {
                    return (rule.field, error)
                }
            default:
                return (rule.field, required()("")!)
            }
        }
        return nil
    }
    
    static func error(code: Int, localizedDescription: String) -> NSError {
        return error(code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
    
    static func error(code: Int, userInfo:[NSObject : AnyObject]? = nil) -> NSError {
        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
    }
    
    static let errorDomain = "com.bekitzur.stringValidation"
    
    enum ErrorCode: Int {
        case TextLength
        case Email
        case Password
        case Username
    }
    
}

extension UITextField: StringValidatable {
    var validationString: String? {
        return text
    }
}
