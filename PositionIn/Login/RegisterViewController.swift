//
//  RegisterViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import BrightFutures
import CleanroomLogger

final class RegisterViewController: BaseLoginViewController {

    @IBAction func didTapSignupButton(sender: AnyObject) {
        
        let validationRules: [StringValidation.ValidationRule] = [
            (emailTextField, StringValidation.sequence([StringValidation.required(),StringValidation.email()]) ),
        ]
        
        if validateInput(validationRules) {
            performSegue(RegisterViewController.Segue.SignUpSegue)
        }
                        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == RegisterViewController.Segue.SignUpSegue {
            if let controller = segue.destinationViewController as? RegisterInfoViewController {
                controller.initialEmail = emailTextField.text
            }
        }
    }
    
    override func keyboardTargetView() -> UIView? {
        return signupButton
    }
    
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didTapSignupButton(textField)
        return false
    }
}