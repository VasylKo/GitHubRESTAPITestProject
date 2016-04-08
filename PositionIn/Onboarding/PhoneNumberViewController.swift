//
//  PhoneNumberViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class PhoneNumberViewController: XLFormViewController {
    
    private enum Tags : String {
        case CountryCode = "CountryCode"
        case Phone = "Phone"
    }
    
    private enum Countries : Int {
        case Kenya = 0, Swizerland, France
        //USA, UK, Swizerland, France, Israel, Russia
        
        static let allValues = [Kenya, Swizerland, France]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.phoneVerification)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIScheme.mainThemeColor
        trackGoogleAnalyticsEvent("Auth", action: "Click", label: "SMS code")
    }
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Your Phone Number", comment: "New post: form caption"))
        
        //Country code section
        let countryCodeSection = XLFormSectionDescriptor.formSectionWithTitle("Join Red Cross Today\nPlease confirm your country code\nand enter your mobile phone number")
        form.addFormSection(countryCodeSection)
        
        let coutryRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.CountryCode.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title:"")
        var selectorOptions: [XLFormOptionsObject] = []
        
        var counter = 0
        for value in Countries.allValues {
            let countryName = self.countryName(value)
            let countryPhoneCode = self.countryPhoneCode(value)
            
            if let countryName = countryName,
                let countryPhoneCode = countryPhoneCode {
                    let optionObject = XLFormOptionsObject(value: counter, displayText: "\(countryName) \(countryPhoneCode)")
                    selectorOptions.append(optionObject)
            }
            counter++
        }
        
        coutryRow.selectorOptions = selectorOptions
        if let firstObject = selectorOptions.first {
            coutryRow.title = firstObject.displayText()
        }
        coutryRow.onChangeBlock = {[unowned coutryRow] oldValue, newValue, descriptor in
            if let newValue = newValue as? XLFormOptionsObject {
                coutryRow.title = newValue.displayText()
                self.countryNumber = newValue.formValue() as? Int
                coutryRow.value = nil
            }
        }
        countryCodeSection.addFormRow(coutryRow)
        
        // Phone number section
        let phoneNumberSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(phoneNumberSection)
        
        let phoneRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Phone.rawValue,
            rowType: XLFormRowDescriptorTypePhone)
        phoneRow.cellConfigAtConfigure["textField.placeholder"] = "Enter your mobile phone number"
        phoneRow.required = true
        phoneRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Please specify a valid phone number",
            comment: "Onboarding"), regex: "^\\+?\\d+$"))
        phoneNumberSection.addFormRow(phoneRow)
        
        self.form = form
    }
    
    func dismissLogin() {
        self.view.endEditing(true)
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        trackGoogleAnalyticsEvent("PhoneVerification", action: "Done")
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        let phoneRow = self.form.formRowWithTag(Tags.Phone.rawValue)
        
        let countryCode: String?
        if let countryNumber = self.countryNumber,
            let country = Countries(rawValue: countryNumber) {
                countryCode = self.countryPhoneCode(country)
        } else {
            countryCode = nil
        }
        
        if let phoneRow = phoneRow?.value {
            let phoneRowString = "\(phoneRow)"
            let phoneNumber : String
            
            if phoneRowString.hasPrefix("+") {
                phoneNumber = phoneRowString
            }
            else {
                if let countryCode = countryCode {
                    phoneNumber = "\(countryCode)\(phoneRowString)"
                }
                else {
                    return
                }
            }
            
            let alertController = UIAlertController(title: NSLocalizedString("Number Confirmation",
                comment: "Onboarding"),
                message: "Is your mobile phone number below correct?\n\(phoneNumber)", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Edit", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Yes", style: .Default) {[weak self] (action) in
                
                trackGoogleAnalyticsEvent("PhoneVerification", action: "PhoneConfirmed")
                
                let smsCode = NSNumber(int: 1)
                api().verifyPhone(phoneNumber, type: smsCode).onSuccess(callback: {[weak self] in
                    let validationController = Storyboards.Onboarding.instantiatePhoneVerificationController()
                    validationController.phoneNumber = phoneNumber
                    self?.navigationController?.pushViewController(validationController, animated: true)
                    })
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private func countryName(let value: Countries) -> String? {
        switch value {
        case .Kenya:
            return "Kenya"
//        case .USA:
//            return "United States"
//        case .UK:
//            return "United Kingdom"
        case .Swizerland:
            return "Swizerland"
        case .France:
            return "France"
//        case .Israel:
//            return "Israel"
//        case .Russia:
//            return "Russia"
        }
    }
    
    private func countryPhoneCode(let value: Countries) -> String? {
        switch value {
        case .Kenya:
            return "+254"
//        case .USA:
//            return "+1"
//        case .UK:
//            return "+44"
        case .Swizerland:
            return "+41"
        case .France:
            return "+33"
//        case .Israel:
//            return "+972"
//        case .Russia:
//            return "+7"
        }
    }
    
    private var countryNumber: Int? = 0
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
}