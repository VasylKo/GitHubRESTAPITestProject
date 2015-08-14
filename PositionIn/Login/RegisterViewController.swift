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
            
            api().createProfile(username: email, password: password).flatMap { _ in
                return api().getMyProfile()
            }.flatMap {
                (userProfile: UserProfile) ->  Future<Void,NSError> in
                var updatedProfile = userProfile
                updatedProfile.firstName = username
                updatedProfile.avatar = NSURL(string:"http://i.imgur.com/5npTFKP.png")
                return api().updateMyProfile(updatedProfile)
            }.flatMap {  (_: Void) -> Future<UserProfile, NSError> in
                return api().getMyProfile()
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