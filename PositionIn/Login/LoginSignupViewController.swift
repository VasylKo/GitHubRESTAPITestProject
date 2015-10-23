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
        performSegue(LoginSignupViewController.Segue.LoginSegueId)
    }
    
    override func keyboardTargetView() -> UIView? {
        return loginButton
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: self,
            handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                
            if error != nil {
                FBSDKLoginManager().logOut()
            } else if result.isCancelled {
                FBSDKLoginManager().logOut()
            } else {
                let fbToken = result.token.tokenString
                
                api().loginViaFB(fbToken).onSuccess { [weak self] _ in
                    Log.info?.message("Logged in")
                    self?.dismissLogin()
                }
            }
        })
    }
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

}
