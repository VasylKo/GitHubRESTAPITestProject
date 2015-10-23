//
//  LoginViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger
import FBSDKCoreKit
import FBSDKLoginKit

final class LoginViewController: BaseLoginViewController {
   
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    @IBAction func didTapForgot(sender: AnyObject) {
        performSegue(LoginViewController.Segue.ForgotPasswordSegueId)
    }
        
    @IBAction func didTapLogin(sender: AnyObject) {
        //TODO: add validation
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            
            api().login(username: username, password: password).onSuccess { [weak self] _ in
                Log.info?.message("Logged in")
                self?.dismissLogin()
            }
            
        } else {
            Log.warning?.message("Invalid input")
        }
    }
    
    
    @IBAction func facebookPressed(sender: AnyObject) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: self,
            handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                
                if error != nil {
                    FBSDKLoginManager().logOut()
                } else if result.isCancelled {
                    FBSDKLoginManager().logOut()
                } else {
                    let fbToken = result.token.tokenString
                    
                    api().loginViaFB(fbToken).onSuccess { [weak self] _ in
                        Log.info?.message("Logged in")
                        self?.dismissLogin()
                    }
                }
        })
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