//
//  LoginViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

final class LoginViewController: BaseLoginViewController {
   
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    @IBAction func didTapForgot(sender: AnyObject) {
        trackGoogleAnalyticsEvent("Auth", action: "Click", label: "Forgot")
        performSegue(LoginViewController.Segue.ForgotPasswordSegueId)
    }
        
    @IBAction func didTapLogin(sender: AnyObject) {
        //TODO: add validation
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            
            api().login(username: username, password: password).onSuccess { [weak self] _ in
                Log.info?.message("Logged in")
                trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Success")
                self?.dismissLogin()
            }.onFailure(callback: { _ in
                trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Fail")
            })
            
        } else {
            Log.warning?.message("Invalid input")
        }
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    
    @IBOutlet private weak var forgotButton: UIButton!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            didTapLogin(textField)
        default:
            return true
        }
        return false
    }
}