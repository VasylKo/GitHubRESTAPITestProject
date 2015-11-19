//
//  ChangePasswordViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 05/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordTextField:
            self.newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            self.confirmNewPasswordTextField.becomeFirstResponder()
        case confirmNewPasswordTextField:
            self.view.endEditing(false)
        default:
            break;
        }
        return true
    }
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        if let oldPassword = self.newPasswordTextField.text,
            let newPassword = self.confirmNewPasswordTextField.text,
            let confirmNewPassword = self.confirmNewPasswordTextField.text {
                if (oldPassword.characters.count == 0 || newPassword.characters.count == 0 || confirmNewPassword.characters.count == 0) {
                    showWarning(NSLocalizedString("Please, fill all fields", comment: "Change Password"))
                    return
                }
                
                if (oldPassword != confirmNewPassword) {
                    showWarning(NSLocalizedString("Passwords should match", comment: "Change Password"))
                    return
                }
                
                let validationRules: [StringValidation.ValidationRule] = [
                    (newPasswordTextField, StringValidation.sequence([StringValidation.required(),StringValidation.password()]))
                ]
                
                if let validationResult = StringValidation.validate(validationRules) {
                    showWarning(validationResult.error.localizedDescription)
                    if let responder = validationResult.field as? UIResponder {
                        responder.becomeFirstResponder()
                    }
                    return
                }
                
                api().changePassword(self.oldPasswordTextField.text,
                    newPassword: self.newPasswordTextField.text).onSuccess(callback: {[weak self] _ in
                        self?.navigationController?.popToRootViewControllerAnimated(true)
                        })
        }
        else {
            showWarning(NSLocalizedString("Please, fill all fields", comment: "Change Password"))
        }
    }
    
    @IBAction func tapOutsideKeyboard(sender: AnyObject) {
        self.view.endEditing(false)
    }
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
}
