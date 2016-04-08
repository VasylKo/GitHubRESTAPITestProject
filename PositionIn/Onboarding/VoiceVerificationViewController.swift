//
//  VoiceVerificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import BrightFutures

class VoiceVerificationViewController: XLFormViewController {

    private enum Tags : String {
        case ValidationCode = "ValidationCode"
    }
    
    var phoneNumber: String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics("VoiceVerificationCode")
    }
    
    //MARK: Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Phone Verification", comment: "New post: form caption"))
        
        // Validation number section
        let phoneNumberSection = XLFormSectionDescriptor.formSectionWithTitle("Voice Verification\na Please tap 'Call Me' and enter\nthe 6-digit code that you hear")
        form.addFormSection(phoneNumberSection)
        let codeRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.ValidationCode.rawValue,
            rowType: XLFormRowDescriptorTypePhone)
        codeRow.cellConfigAtConfigure["textField.placeholder"] = "Enter your validation code"
        codeRow.required = true
        codeRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect validation code",
            comment: "Onboarding"), regex: "^\\d+$"))
        codeRow.onChangeBlock  = {[weak self] oldValue, newValue, descriptor in
            if let newValue = newValue as? String,
                let oldValue = oldValue as? String {
                if newValue.characters.count == 6 && newValue.compare(oldValue) != .OrderedSame {
                    self?.doneButtonPressed()
                }
                else if newValue.characters.count > 6 {
                    descriptor.value = oldValue
                    Queue.main.async { _ in
                        self?.reloadFormRow(descriptor)
                    }
                }
            }
        }
        phoneNumberSection.addFormRow(codeRow)

        let voiceCallSection = XLFormSectionDescriptor.formSection()
        let voiceVerificationRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Call Me"))
        voiceVerificationRow.cellConfig["backgroundColor"] = UIScheme.mainThemeColor
        voiceVerificationRow.cellConfig["textLabel.textColor"] = UIColor.whiteColor()
        
        voiceVerificationRow.action.formBlock = { [weak self] row in
            if let phoneNumber = self?.phoneNumber {
                //2 - api type for phone validation call call
                let phoneCallCode = NSNumber(int: 2)
                api().verifyPhone(phoneNumber, type: phoneCallCode)
            }
        }
        voiceCallSection.addFormRow(voiceVerificationRow)
        form.addFormSection(voiceCallSection)

        self.form = form
    }
    
    //MARK: Target-Action
    
    @IBAction func doneButtonPressed() {
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        let codeRow = self.form.formRowWithTag(Tags.ValidationCode.rawValue)
        
        if let codeRowValue = codeRow?.value,
            let phoneNumber = self.phoneNumber {
                let codeString = "\(codeRowValue)"
                api().verifyPhoneCode(phoneNumber, code: codeString).onSuccess(callback: {[weak self] isExistingUser in
                    if isExistingUser {
                        trackGoogleAnalyticsEvent("Auth", action: "Click", label: "SMS verification", value: NSNumber(int: 1))
                        api().login(username: nil, password: nil, phoneNumber: phoneNumber, phoneVerificationCode: codeString).onSuccess { [weak self] _ in
                            api().pushesRegistration()
                            self?.view.resignFirstResponder()
                            self?.dismissLogin()
                            }.onFailure(callback: { _ in
                                trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Fail")
                            })
                    }
                    else {
                        //register
                        if let strongSelf = self {
                            trackGoogleAnalyticsEvent("Auth", action: "Click", label: "SMS verification", value: NSNumber(int: 0))
                            MembershipRouterImplementation().showMembershipMemberProfile(from: strongSelf, phoneNumber: strongSelf.phoneNumber!, validationCode: codeString)
                        }
                    }
                    })
        }
    }
    
    //MARK: Private
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func dismissLogin() {
        self.view.endEditing(true)
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
