//
//  PhoneVerificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 20/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class PhoneVerificationViewController: XLFormViewController {
    
    private enum Tags : String {
        case ValidationCode = "ValidationCode"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("You Phone Number", comment: "New post: form caption"))
        
        // Validation number section
        let phoneNumberSection = XLFormSectionDescriptor.formSectionWithTitle("We send you an SMS with\na verification code")
        form.addFormSection(phoneNumberSection)
        
        let codeRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.ValidationCode.rawValue,
            rowType: XLFormRowDescriptorTypeDecimal)
        codeRow.cellConfigAtConfigure["textField.placeholder"] = "Enter you validation code"
        codeRow.required = true
        codeRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect validation code",
            comment: "Onboarding"), regex: "^\\d+$"))
        phoneNumberSection.addFormRow(codeRow)
        
        self.form = form
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        let codeRow = self.form.formRowWithTag(Tags.ValidationCode.rawValue)
        
        if let codeRowString = codeRow?.value,
            let phoneNumber = self.phoneNumber {
                api().verifyPhoneCode(phoneNumber, code: "\(codeRowString)").onSuccess(callback: {[weak self] isExistingUser in
                    if isExistingUser {
                        api().login(username: nil, password: nil, phoneNumber: phoneNumber, phoneVerificationCode: "\(codeRowString)").onSuccess { [weak self] _ in
                            Log.info?.message("Logged in")
                            trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Success")
                            self?.dismissLogin()
                            }.onFailure(callback: { _ in
                                trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Fail")
                            })
                    }
                    else {
                        //register
                        self?.performSegue(PhoneVerificationViewController.Segue.ProfileSegueId)
                    }
                    })
        }
    }
    
    func dismissLogin() {
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var phoneNumber: String?
}
