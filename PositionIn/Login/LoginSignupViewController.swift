//
//  LoginSignupViewController.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import UIKit
import CleanroomLogger
import FBSDKCoreKit
import FBSDKLoginKit

final class LoginSignupViewController: BaseLoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
        
    @IBAction func didTapLogin(sender: AnyObject) {
        trackGoogleAnalyticsEvent("Auth", action: "Click", label: "Login")
        performSegue(LoginSignupViewController.Segue.LoginSegueId)
    }
    

    @IBAction func didTapSignUp(sender: AnyObject) {
        trackGoogleAnalyticsEvent("Auth", action: "Click", label: "Signup")
        performSegue(LoginSignupViewController.Segue.SignUpSegueId)
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

}
