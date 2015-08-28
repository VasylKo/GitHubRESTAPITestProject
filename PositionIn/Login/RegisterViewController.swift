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
        
        let username = emailTextField.text
        if let error = EmailTextValidator.validate(string: username) {
            let  alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        performSegue(RegisterViewController.Segue.SignUpSegue)
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