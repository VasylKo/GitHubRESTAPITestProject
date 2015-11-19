//
//  PhoneNumberViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class PhoneNumberViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: NSLocalizedString("Number Confirmation", comment: "Onboarding"), message: "Is your phone number below correct?\n\(self.phoneNumberTextField.text!)", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Edit", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .Default) {[weak self] (action) in
            self?.performSegue(PhoneNumberViewController.Segue.PhoneNumberSegueId)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
}