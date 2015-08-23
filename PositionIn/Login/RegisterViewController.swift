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
        //TODO: add validation
        if let username = usernameTextField.text,
           let password = passwordTextField.text,
           let email = emailTextField.text {
            
            let lastName: String? = nil
            
            api().register(username: email, password: password, firstName: username, lastName: lastName).flatMap {
                (userProfile: UserProfile) ->  Future<Void,NSError> in
                var updatedProfile = userProfile
                updatedProfile.avatar = NSURL(string:"http://i.imgur.com/5npTFKP.png")
                return api().updateMyProfile(updatedProfile)
            }.onFailure { error in
                Log.error?.value(error)
            }.onSuccess { [weak self] _ in
                Log.info?.message("Registration done")
                self?.sideBarController?.executeAction(.ForYou)
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }

    
    override func keyboardTargetView() -> UIView? {
        return signupButton
    }
    
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
}