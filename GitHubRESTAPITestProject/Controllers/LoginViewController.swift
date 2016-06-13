//
//  LoginViewController.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 27/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func didTapLoginButton()
    func didTapCancel()
}

class LoginViewController: UIViewController {

    weak var delegate: LoginViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func loginButtonTapped(sender: UIButton) {
        delegate?.didTapLoginButton()
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        delegate?.didTapCancel()
    }

}
