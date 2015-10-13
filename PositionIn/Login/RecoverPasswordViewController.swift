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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.borderColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46).CGColor
        submitButton.layer.borderWidth = 1
    }
    
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