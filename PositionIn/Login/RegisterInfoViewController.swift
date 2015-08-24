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

final class RegisterInfoViewController: BaseLoginViewController {
    
    @IBAction func didTapSignupButton(sender: AnyObject) {
        //TODO: add validation
    }
    
    override func keyboardTargetView() -> UIView? {
        return signupButton
    }
    
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var firstnameTextField: UITextField!
    @IBOutlet private weak var lastnameTextField: UITextField!
}