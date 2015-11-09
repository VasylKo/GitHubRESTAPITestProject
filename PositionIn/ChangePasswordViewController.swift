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
        
        
    }
    
    @IBAction func tapOutsideKeyboard(sender: AnyObject) {
        self.view.endEditing(false)
    }
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
}
