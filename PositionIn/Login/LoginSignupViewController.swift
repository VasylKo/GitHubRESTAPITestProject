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
        signupButton.layer.borderColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46).CGColor
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        volunteerButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
        
    @IBAction func didTapLogin(sender: AnyObject) {
        trackEventToAnalytics(AnalyticCategories.auth, action: AnalyticActios.click, label: NSLocalizedString("Login"))
        performSegue(LoginSignupViewController.Segue.LoginSegueId)
    }
    

    @IBAction func didTapSignUp(sender: AnyObject) {
        trackEventToAnalytics(AnalyticCategories.auth, action: AnalyticActios.click, label: NSLocalizedString("Signup"))
        performSegue(LoginSignupViewController.Segue.SignUpSegueId)
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var volunteerButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

}
