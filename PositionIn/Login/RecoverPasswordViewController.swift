//
//  RecoverPasswordViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

final class RecoverPasswordViewController: BaseLoginViewController {
    
   
    
    @IBAction func didTapSubmitButton(sender: AnyObject) {
        Log.debug?.message("Should call recover")
    }
    
    
    override func keyboardTargetView() -> UIView? {
        return submitButton
    }

    @IBOutlet private weak var submitButton: UIButton!
}

extension RecoverPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didTapSubmitButton(textField)
        return false
    }
}