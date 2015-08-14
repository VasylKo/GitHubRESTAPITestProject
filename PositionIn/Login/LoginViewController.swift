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

    @IBAction func didTapClose(sender: AnyObject) {
        sideBarController?.executeAction(.ForYou)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapLogin(sender: AnyObject) {
        //TODO: add validation
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            api().auth(username: username, password: password).onSuccess() { [weak self] userProfile in
                self?.didTapClose(sender)
            }
        } else {
            Log.warning?.message("Invalid input")
        }
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBOutlet private weak var loginButton: UIButton!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
}