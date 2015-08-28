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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = initialEmail
    }
    
    @IBAction func didTapSignupButton(sender: AnyObject) {
       
        let username = emailTextField.text
        if let error = EmailTextValidator.validate(string: username) {
            let  alert = UIAlertView(title: "Errro", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        let password = passwordTextField.text
        if let error = PasswordTextValidator.validate(string: password) {
            let  alert = UIAlertView(title: "Errro", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        let firstName = firstnameTextField.text
        if let error = NameTextValidator.validate(string: firstName) where count(firstName) > 0 {
            let  alert = UIAlertView(title: "Errro", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        let lastName = lastnameTextField.text
        if let error = NameTextValidator.validate(string: lastName) where count(lastName) > 0 {
            let  alert = UIAlertView(title: "Errro", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        
        api().register(username: username, password: password, firstName: firstName, lastName: lastName).flatMap {
            (userProfile: UserProfile) ->  Future<Void,NSError> in
            var updatedProfile = userProfile
            updatedProfile.avatar = NSURL(string:"http://i.imgur.com/5npTFKP.png")
            return api().updateMyProfile(updatedProfile)
            }.flatMap { _ in
                return api().isUserAuthorized()
            }.onFailure { error in
                Log.error?.value(error)
            }.onSuccess { [weak self] _ in
                Log.info?.message("Registration done")
                self?.sideBarController?.executeAction(.ForYou)
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func keyboardTargetView() -> UIView? {
        return signupButton
    }
    
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var firstnameTextField: UITextField!
    @IBOutlet private weak var lastnameTextField: UITextField!
    
    var initialEmail: String?
}