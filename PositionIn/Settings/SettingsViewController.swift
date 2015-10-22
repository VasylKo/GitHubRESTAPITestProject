//
//  SettingsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import MessageUI

class SettingsViewController: BesideMenuViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.versionLabel.text = AppConfiguration().appVersion
        customizeButton(self.signOutButton)
        customizeButton(self.termsConditionsButton)
        customizeButton(self.supportButton)
        customizeButton(self.passwordButton)
        
        self.signOutButton.hidden = !api().isUserAuthorized()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = self.contentView.frame
        frame.size.height = CGRectGetMaxY(self.versionLabel.frame) + 10
        self.contentView.frame = frame
        
        self.scrollView.contentSize = contentView.frame.size
    }
    
    func customizeButton(button: UIButton) {
        button.layer.borderColor = UIColor(white: 213/255, alpha: 1).CGColor
        button.layer.borderWidth = 1 / UIScreen.mainScreen().scale
    }
    
    @IBAction func spreadTheWordPressed(sender: AnyObject) {
        self.showMailControllerWithRecepientEmail(nil)
    }

    @IBAction func changePasswordPressed(sender: AnyObject) {
        
    }
    
    @IBAction func contactSupportPressed(sender: AnyObject) {
        self.showMailControllerWithRecepientEmail("support@positionin.com")
    }
    
    @IBAction func signOutPressed(sender: AnyObject) {
        api().logout().onComplete {[weak self] _ in
            self?.sideBarController?.executeAction(.Login)
        }
    }
    
    func showMailControllerWithRecepientEmail(email: String?) {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            if let email = email {
                mailController.setToRecipients([email])
            }
            self.presentViewController(mailController, animated: true, completion: nil)
        }
        else {
            let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email",
                message: "Your device could not send e-mail.  Please check e-mail configuration and try again.",
                delegate: nil, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult,
        error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet private weak var signOutButton: UIButton!
    @IBOutlet private weak var termsConditionsPressed: UIButton!
    @IBOutlet private weak var termsConditionsButton: UIButton!
    @IBOutlet private weak var supportButton: UIButton!
    @IBOutlet private weak var spreadTheWordButton: UIButton!
    @IBOutlet private weak var passwordButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
}