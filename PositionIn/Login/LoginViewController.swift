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
        performSegue(LoginViewController.Segue.ForgotPasswordSegueId)
    }
    
    @IBAction func didTapClose(sender: AnyObject) {
        //Use existing session or register new
        api().session().recoverWith { _ in
            return api().register().map { _ in
                return ()
            }
        }.onSuccess { [weak self] _ in
            Log.info?.message("Anonymous login done")
            self?.dismissLogin()
        }.onFailure { error in
            Log.error?.value(error)
        }
    }
    
    func dismissLogin() {
        sideBarController?.executeAction(.ForYou)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapLogin(sender: AnyObject) {
        //TODO: add validation
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            
            api().login(username: username, password: password).onSuccess { [weak self] _ in
                Log.info?.message("Logged in")
                self?.dismissLogin()
            }.onFailure { error in
                Log.error?.value(error)
            }
            
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