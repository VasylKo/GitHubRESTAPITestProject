//
//  PhoneNumberViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CHCSVParser

class PhoneNumberViewController: XLFormViewController {
    
    private enum Tags : String {
        case CountryCode = "CountryCode"
        case Phone = "Phone"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.phoneVerification)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.prepareCountryPhoneCodes()
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareCountryPhoneCodes()
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIScheme.mainThemeColor
        trackEventToAnalytics(AnalyticCategories.auth, action: AnalyticActios.click, label: NSLocalizedString("SMS code"))
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
        
        var kenyaSelectorOption: XLFormOptionsObject?
        
        for (index, element) in phonesDictionary.enumerate() {
            let country = element["countryName"]
            let code = element["phoneCode"]
            
            if let countryName = country,
                let countryPhoneCode = code {
                    
                    let optionObject = XLFormOptionsObject(value: index, displayText: "\(countryName) \(countryPhoneCode)")
                    if countryName == "Kenya" {
                        kenyaSelectorOption = optionObject
                    }
                    selectorOptions.append(optionObject)
            }
        }
        
        coutryRow.selectorOptions = selectorOptions
        if let kenyaSelectorOption = kenyaSelectorOption {
            coutryRow.title = kenyaSelectorOption.displayText()
        }
        coutryRow.onChangeBlock = {[unowned coutryRow] oldValue, newValue, descriptor in
            if let newValue = newValue as? XLFormOptionsObject {
                coutryRow.title = newValue.displayText()
                let countryNumber = newValue.formValue() as? Int
                if let countryNumber = countryNumber {
                    let countryInfo = self.phonesDictionary[countryNumber]
                    self.countryPhoneCode = countryInfo["phoneCode"]
                }
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
    
    func prepareCountryPhoneCodes() {
        let csvFile = NSBundle.mainBundle().pathForResource("country-codes", ofType: "csv")
        let content = NSArray(contentsOfCSVFile: csvFile)
        
        for (index, element) in content.enumerate() {
            if index > 0 {
                if let element = element as? NSArray {
                    let countryName = element[0]
                    let phoneCode = element[1]
                    
                    if var countryName = countryName as? String, var phoneCode = phoneCode as? String {
                        countryName = countryName.stringByReplacingOccurrencesOfString("\"", withString: "")
                        phoneCode = "+\(phoneCode)"
                        let array = ["countryName" : countryName, "phoneCode" : phoneCode]
                        phonesDictionary.append(array)
                    }
                }
            }
        }
    }
    
    func dismissLogin() {
        self.view.endEditing(true)
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        trackEventToAnalytics(AnalyticCategories.phoneVerification, action: AnalyticActios.done)
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        let phoneRow = self.form.formRowWithTag(Tags.Phone.rawValue)
        
        if let phoneRow = phoneRow?.value, countryNumber = self.countryPhoneCode {
            let phoneRowString = "\(phoneRow)"
            let phoneNumber : String
            
            if phoneRowString.hasPrefix("+") {
                phoneNumber = phoneRowString
            }
            else {
                phoneNumber = "\(countryNumber)\(phoneRowString)"
            }
            
            let alertController = UIAlertController(title: NSLocalizedString("Number Confirmation",
                comment: "Onboarding"),
                message: "Is your mobile phone number below correct?\n\(phoneNumber)", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Edit", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Yes", style: .Default) {[weak self] (action) in
                self?.navigationItem.rightBarButtonItem?.enabled = false;
                trackEventToAnalytics(AnalyticCategories.phoneVerification, action: AnalyticActios.phoneConfirmed)
                
                let smsCode = NSNumber(int: 1)
                api().verifyPhone(phoneNumber, type: smsCode).onSuccess(callback: {[weak self] in
                    let validationController = Storyboards.Onboarding.instantiatePhoneVerificationController()
                    validationController.phoneNumber = phoneNumber
                    self?.navigationController?.pushViewController(validationController, animated: true)
                    self?.navigationItem.rightBarButtonItem?.enabled = true;
                    }).onFailure(callback: {[weak self] _ in
                        self?.navigationItem.rightBarButtonItem?.enabled = true;
                        })
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private var countryPhoneCode: String? = "+254"
    private var phonesDictionary: [[String: String]] = []
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
}