//
//  LoginSignupViewController.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import UIKit

class LoginSignupViewController: UIViewController {
    
    @IBAction func didTapClose(sender: AnyObject) {
        sideBarController?.executeAction(.ForYou)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapLogin(sender: AnyObject) {
        performSegue(LoginSignupViewController.Segue.LoginSegueId)
    }
    
    func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBOutlet private weak var loginButton: UIButton!

}
