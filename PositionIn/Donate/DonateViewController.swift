//
//  DonateViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Braintree
import Box

class DonateViewController: XLFormViewController, PaymentReponseDelegate {
    private enum Tags : String {
        case Project = "Project"
        case Money = "Money"
        case Payment = "Payment"
        case Confirm = "Confirm"
        case Error = "Error"
    }
    
    var product: Product?
    
    private var amount:Int = 0;
    private var paymentType:String?
    private var finishedSuccessfully = false
    private var errorSection:XLFormSectionDescriptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIScheme.mainThemeColor
        self.initializeForm()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(finishedSuccessfully) {
            let paymentCompleteController = Storyboards.Onboarding.instantiatePaymentCompletedViewController()
            paymentCompleteController.projectName = self.product?.name
            paymentCompleteController.projectIconURL = self.product?.imageURL
            
            self.navigationController?.pushViewController(paymentCompleteController, animated: true)
        }
    }
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func initializeForm() {
        
        let form = XLFormDescriptor(title: NSLocalizedString("Donate", comment: "Donate"))
        
        //Error
        errorSection = XLFormSectionDescriptor()
        form.addFormSection(errorSection!)
        
        let errorRow = XLFormRowDescriptor(tag: Tags.Error.rawValue, rowType: XLFormRowDescriptorTypeError, title:"Error")
        errorRow.cellConfigAtConfigure["backgroundColor"] = UIColor.purpleColor()
        errorRow.cellConfig["textLabel.textAlignment"] =  NSTextAlignment.Left.rawValue
        errorRow.disabled = NSNumber(bool: true)
        
        errorSection!.addFormRow(errorRow)
        errorSection!.hidden = NSNumber(bool: true)
        
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Project.rawValue,
            rowType: XLFormRowDescriptorTypeDonate)
        if let product = self.product {
            donateProjectRow.cellConfigAtConfigure["name"] = product.name
            
            if let imageURL = product.imageURL {
                donateProjectRow.cellConfigAtConfigure["projectIconURL"] = imageURL
            }
        }
        
        donateToSection.addFormRow(donateProjectRow)
        
        let donatationSection = XLFormSectionDescriptor.formSectionWithTitle("Donation Amount (KSH)")
        form.addFormSection(donatationSection)
        
        let donationRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Money.rawValue,
            rowType: XLFormRowDescriptorTypeDecimal)
        donationRow.required = true
        donationRow.cellConfigAtConfigure["textField.placeholder"] = "Set a donation"
        donationRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        donationRow.onChangeBlock =  { [weak self] oldValue, newValue, _ in
            if let value = newValue as? NSNumber {
                self?.amount = Int(value)
            } else {
                self?.amount = 0
            }
        }
        
        donatationSection.addFormRow(donationRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentRow.onChangeBlock = { [weak self] oldValue, newValue, _ in
            if let box: Box<CardItem> = newValue as? Box {
                self?.paymentType = CardItem.cardPayment(box.value)
            } else {
                self?.paymentType = nil
            }
        }
        
        paymentSection.addFormRow(paymentRow)
        
        let confirmDonation = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmDonation)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Confirm.rawValue,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Confirm Donation", comment: "Payment"))
        
        confirmRow.cellConfig["backgroundColor"] = UIScheme.mainThemeColor
        confirmRow.cellConfig["textLabel.color"] = UIColor.whiteColor()
        confirmRow.cellConfig["textLabel.textAlignment"] =  NSTextAlignment.Center.rawValue

        confirmRow.action.formBlock = { [weak self] (sender: XLFormRowDescriptor!) -> Void in
            if (self?.paymentType != nil && self?.amount != 0) {
                self!.performSegueWithIdentifier("Show\((self?.paymentType)!)", sender: self!)
                self?.setError(true, error: nil)
            } else {
                if(self?.amount == 0) {
                   self?.setError(false, error: "The donation amount connot be 0")
                } else {
                   self?.setError(false, error: "You must select a payment method")
                }
            }
            
            self?.deselectFormRow(sender)
        }
        
        confirmDonation.addFormRow(confirmRow)
        confirmDonation.footerTitle = "By purchasing, you agree to Red Cross Terms of service and Privecy Policy"
        
        self.form = form
    }
    
    func setError(hidden: Bool, error: String?) {
        if(hidden || error == nil) {
            errorSection?.hidden = NSNumber(bool: true)
        } else {
            errorSection?.hidden = NSNumber(bool: false)
            let row = errorSection?.formRows.firstObject as! XLFormRowDescriptor
            
            row.title = error ?? ""
            self.reloadFormRow(row)
        }
    }
    
    func paymentReponse(success: Bool, err: String?) {
        if(success) {
            finishedSuccessfully = true
            setError(true, error: nil)
        } else {
            setError(false, error: err)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if var paymentProtocol = segue.destinationViewController as? PaymentProtocol {
            paymentProtocol.amount = self.amount
            paymentProtocol.delegate = self
            paymentProtocol.productName = "Donation"
            paymentProtocol.itemId = self.product?.objectId
        }
    }
}