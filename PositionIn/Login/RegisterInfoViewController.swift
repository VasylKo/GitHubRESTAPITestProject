//
//  RegisterInfoViewController
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
        
        signupButton.layer.borderColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46).CGColor
        signupButton.layer.borderWidth = 1
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
            
            trackEventToAnalytics(AnalyticCategories.auth, action: c, label: NSLocalizedString("Signup Complete"))
            
            let firstName = firstnameTextField.text
            let lastName = lastnameTextField.text
            let email = emailTextField.text
            
            api().register(username: username, password: password, phoneNumber: nil, phoneVerificationCode: nil, firstName: firstName, lastName: lastName, email: email).onSuccess {
                [weak self] _ in
                trackEventToAnalytics(AnalyticCategories.status, action: AnalyticActios.click, label: NSLocalizedString("Auth Success"))
                Log.info?.message("Registration done")
                self?.sideBarController?.executeAction(SidebarViewController.defaultAction)
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }.onSuccess(callback: { _ in
                    api().pushesRegistration()
                }).onFailure(callback: {_ in
                trackEventToAnalytics(AnalyticCategories.status, action: AnalyticActios.click, label: NSLocalizedString("Auth Fail"))
            })
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