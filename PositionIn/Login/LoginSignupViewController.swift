//
//  LoginSignupViewController.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import UIKit

final class LoginSignupViewController: BaseLoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.layer.borderColor = UIColor.bt_colorWithBytesR(225, g: 0, b: 38).CGColor
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        volunteerButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
        
    @IBAction func didTapLogin(sender: AnyObject) {
        performSegue(LoginSignupViewController.Segue.LoginSegueId)
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var volunteerButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

}
