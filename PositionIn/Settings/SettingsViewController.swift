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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.settings)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = self.contentView.frame
        frame.size.height = CGRectGetMaxY(self.versionLabel.frame) + 10
        self.contentView.frame = frame
        
        self.scrollView.contentSize = contentView.frame.size
    }
    
    @IBAction func termsConditionsButtonPressed(sender: AnyObject) {
        let url: NSURL? = NSURL(string: "http://www.redcross.or.ke/")
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func customizeButton(button: UIButton) {
        button.layer.borderColor = UIColor(white: 213/255, alpha: 1).CGColor
        button.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        button.setBackgroundImage(self.imageWithColor(UIColor(white: 213/255, alpha: 1)), forState: .Highlighted)
        button.setBackgroundImage(self.imageWithColor(UIColor.whiteColor()), forState: .Normal)
    }
    
    @IBAction func spreadTheWordPressed(sender: AnyObject) {
        self.showMailControllerWithRecepientEmail(nil)
    }

    @IBAction func changePasswordPressed(sender: AnyObject) {
        if api().isUserAuthorized() {
            let changePasswordController = Storyboards.Main.instantiateChangePasswordController()
            self.navigationController?.pushViewController(changePasswordController, animated: true)
        }
    }
    
    @IBAction func contactSupportPressed(sender: AnyObject) {
        self.showMailControllerWithRecepientEmail("rcapp@redcross.or.ke")
    }
    
    @IBAction func signOutPressed(sender: AnyObject) {
        api().logoutFromServer().onSuccess {[weak self] _ in
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult,
        error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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