//
//  LoginViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class LoginViewController: BaseLoginViewController {
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    @IBAction func didTapClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapLogin(sender: AnyObject) {
        Log.debug?.message("Should call login")
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBOutlet private weak var loginButton: UIButton!
    
}