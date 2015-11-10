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
        passwordTextField.becomeFirstResponder()
    }    
    
    @IBAction func didTapSignupButton(sender: AnyObject) {
        let validationRules: [StringValidation.ValidationRule] = [
            (emailTextField, StringValidation.sequence([StringValidation.required(),StringValidation.email()]) ),
            (passwordTextField, StringValidation.sequence([StringValidation.required(),StringValidation.password()]) ),
            (firstnameTextField, StringValidation.name()),
            (lastnameTextField, StringValidation.name()),
        ]
        
        if validateInput(validationRules) {
            guard let username = emailTextField.text,
                password = passwordTextField.text else {
                    return
            }
            
            let firstName = firstnameTextField.text
            let lastName = lastnameTextField.text
            
            api().register(username: username, password: password, firstName: firstName, lastName: lastName).onSuccess {
                [weak self] _ in
                
                let tracker = GAI.sharedInstance().defaultTracker
                let builder = GAIDictionaryBuilder.createEventWithCategory("Auth",
                    action: "Click", label: "Signup", value:nil)
                tracker.send(builder.build() as [NSObject : AnyObject])
                
                Log.info?.message("Registration done")
                self?.sideBarController?.executeAction(SidebarViewController.defaultAction)
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        } //validation
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

extension RegisterInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            firstnameTextField.becomeFirstResponder()
        case firstnameTextField:
            firstnameTextField.resignFirstResponder()
            lastnameTextField.becomeFirstResponder()
        case lastnameTextField:
            lastnameTextField.resignFirstResponder()
            didTapSignupButton(textField)
        default:
            return true
        }
        return false
    }
}