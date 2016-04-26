//
//  MailComposeViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 20/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import MessageUI

final class MailComposeViewController: MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    
    typealias Complition = () -> ()
    
    static func presentMailControllerFrom(viewController: UIViewController, recipientsList recipients: [String], completion: Complition? = nil) {
        let mailComposerVC = MailComposeViewController()
        mailComposerVC.mailComposeDelegate = mailComposerVC
        mailComposerVC.setToRecipients(recipients)
        mailComposerVC.complition = completion
        
        //SetupUI
        mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        mailComposerVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if MFMailComposeViewController.canSendMail() {
            viewController.presentViewController(mailComposerVC, animated: true, completion: {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            })
        } else {
            mailComposerVC.showSendMailErrorAlert()
        }
    }
    
    private var complition: Complition?

    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("Could Not Send Email"),
            message: NSLocalizedString("Your device could not send e-mail.  Please check e-mail configuration and try again."),
            delegate: self,
            cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        complition?()
        dismissViewControllerAnimated(true, completion: nil)
    }
}