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
    var donationType: HomeItem = .Donate
    
    private var amount:Int = 0;
    private var paymentType:String?
    private var finishedSuccessfully = false
    private var errorSection:XLFormSectionDescriptor?
    private weak var confirmRowDescriptor: XLFormRowDescriptor?
    
    internal var viewControllerToOpenOnComplete: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIScheme.mainThemeColor
        
        let rightBarButtomItem = UIBarButtonItem(image: UIImage(named: "info_button_icon"), style: .Plain, target: self, action: "questionTapped")
        self.navigationItem.rightBarButtonItem = rightBarButtomItem
        
        self.title = NSLocalizedString("Donate")
        
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sendScreenNameToAnalytics()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(finishedSuccessfully) {
            let paymentCompleteController = Storyboards.Onboarding.instantiatePaymentCompletedViewController()
            paymentCompleteController.projectName = self.product?.name ?? NSLocalizedString("Kenya Red Cross Society")
            paymentCompleteController.projectIconURL = self.product?.imageURL
            paymentCompleteController.amountDonation = amount
            
            paymentCompleteController.viewControllerToOpenOnComplete = viewControllerToOpenOnComplete
            
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
        
        let donatationSectionTitle = "Donation Amount (\(AppConfiguration().currencySymbol))"
        let donatationSection = XLFormSectionDescriptor.formSectionWithTitle(donatationSectionTitle)
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
        donationRow.addValidator(DonateValidator())
        
        donatationSection.addFormRow(donationRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentRow.required = true
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
            title: NSLocalizedString("Proceed to Donate"))
        confirmRowDescriptor = confirmRow
        confirmRow.disabled = true
        confirmRow.cellConfig["backgroundColor"] = UIScheme.disableActionColor
        confirmRow.cellConfig["textLabel.color"] = UIColor.whiteColor()
        confirmRow.cellConfig["textLabel.textAlignment"] =  NSTextAlignment.Center.rawValue

        confirmRow.action.formBlock = { [weak self] row in
            self?.deselectFormRow(row)
            
            let validationErrors : Array<NSError> = self?.formValidationErrors() as! Array<NSError>
            if (validationErrors.count > 0){
                return
            }
            
            self?.sendDonationEventToAnalytics()
            
            self?.performSegueWithIdentifier("Show\((self?.paymentType)!)", sender: self!)
            self?.setError(true, error: nil)
        }
        
        confirmDonation.addFormRow(confirmRow)
        confirmDonation.footerTitle = "By purchasing, you agree to Red Cross Terms of service and Privecy Policy"
        
        self.form = form
    }

    @objc func questionTapped() {
        let controller = DonateInfoViewController(nibName: "DonateInfoViewController",
                                                  bundle: nil)
        controller.donateToString = self.product?.name
        self.navigationController?.pushViewController(controller, animated: true)
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
            paymentProtocol.productName = self.product?.name
            paymentProtocol.product = self.product
            paymentProtocol.itemId = self.product?.objectId
        }
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        if let confirmRowDescriptor = confirmRowDescriptor {
            let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
            confirmRowDescriptor.disabled = hasErrors
            confirmRowDescriptor.cellConfig["backgroundColor"] = backgroundColor
            updateFormRow(confirmRowDescriptor)
        }
    }
    
    //MARK: - Analytic tracking
    
    private func sendDonationEventToAnalytics() {
        //Send tracking enevt
        let donationTypeName = donationType.displayString().stringByReplacingOccurrencesOfString(" ", withString: "") ?? "Unknown donation source"
        let paymentTypeLabel = paymentType ?? "Can't get type"
        let paymentAmountNumber = NSNumber(integer: amount ?? 0)
        trackGoogleAnalyticsEvent(donationTypeName, action: "ProceedToPay", label: paymentTypeLabel, value: paymentAmountNumber)
    }
    
    private func sendScreenNameToAnalytics() {
        //Send tracking enevt
        let screenName = donationType.displayString().stringByReplacingOccurrencesOfString(" ", withString: "") ?? "Unknown donation source"
        trackScreenToAnalytics(screenName + "Donate")
    }
    
    
}

extension DonateViewController {
    internal class DonateValidator: NSObject, XLFormValidatorProtocol {
        @objc func isValid(row: XLFormRowDescriptor!) -> XLFormValidationStatus {
            var msg = ""
            var status = false
            if let value = row.value as? NSNumber where value.intValue > 0 {
                msg = NSLocalizedString("Entered value is valid")
                status = true
            } else {
                msg = NSLocalizedString("Entered value is invalid")
                status = false
            }
            return XLFormValidationStatus(msg: msg, status: status, rowDescriptor: row)
        }
    }
}