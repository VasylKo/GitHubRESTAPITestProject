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
    
    private static let mpesaPeymentAmountErrorMessage = NSLocalizedString("The minimum amount should be 10 for M-Pesa payment", comment: "Mpesa payment amount warning")

    
    enum DonationType: Int {
        case Unknown = 0
        case Project, EmergencyAlert, Donation, FeedEmergencyAlert
    }
    
    var product: Product?
    var donationType: DonationType = .Donation
    
    private var amount:Int = 0
     
    private var selectedCardType: CardItem?
    private var paymentType: String?
    private var finishedSuccessfully = false
    private var errorSection:XLFormSectionDescriptor?
    private weak var confirmRowDescriptor: XLFormRowDescriptor?
    private weak var paymentTypeRowDescriptor: XLFormRowDescriptor?
    private weak var paymentAmountWarningRowDescriptor: XLFormRowDescriptor?
    private var cardTypeValidator = CardTypeValidator()
    
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
                self?.sendDonationEventToAnalytics(action: AnalyticActios.setDonation, label: "")
            } else {
                self?.amount = 0
            }
        }
        donationRow.addValidator(DonateValidator())
        
        donatationSection.addFormRow(donationRow)
        
        //Payment amount worning row
        let paymentAmountWorningRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeDonationPaymentAmountCell)
        paymentAmountWorningRow.cellConfigAtConfigure["textToShow"] = DonateViewController.mpesaPeymentAmountErrorMessage
        paymentAmountWorningRow.hidden = true
        paymentAmountWarningRowDescriptor = paymentAmountWorningRow
        donatationSection.addFormRow(paymentAmountWorningRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        //MPESA Bonga pin row
        let mpesaBongoPinRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeMPesaBongaPinView)
        mpesaBongoPinRow.hidden = true
        
        //Select payment method row
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentTypeRowDescriptor = paymentRow
        paymentRow.required = true
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentRow.addValidator(cardTypeValidator)
        paymentRow.onChangeBlock = { [weak self] oldValue, newValue, _ in
            if let box: Box<CardItem> = newValue as? Box {
                self?.paymentType = CardItem.cardPayment(box.value)
                self?.selectedCardType = box.value
                self?.sendDonationEventToAnalytics(action: AnalyticActios.selectPaymentMethod)
                
                //Show M-Pesa additional info row
                mpesaBongoPinRow.hidden = box.value != .MPesa

            } else {
                self?.paymentType = nil
            }
        }
        
        paymentSection.addFormRow(paymentRow)
        paymentSection.addFormRow(mpesaBongoPinRow)
        
        
        
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
            
            self?.sendDonationEventToAnalytics(action: AnalyticActios.proceedToPay)
            
            self?.performSegueWithIdentifier("Show\((self?.paymentType)!)", sender: self!)
            self?.setError(true, error: nil)
        }
        
        confirmDonation.addFormRow(confirmRow)
            confirmDonation.footerTitle = "By donating, you agree to Red Cross Terms of service and Privacy Policy"
        
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
            sendDonationEventToAnalytics(action: AnalyticActios.paymentOutcome, label: NSLocalizedString("Payment Completed"))
        } else {
            setError(false, error: err)
            sendDonationEventToAnalytics(action: AnalyticActios.paymentOutcome, label: err)
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
        
        guard   let paymentTypeRowDescriptor = paymentTypeRowDescriptor,
                    confirmRowDescriptor = confirmRowDescriptor,
                    paymentAmountWarningRowDescriptor = paymentAmountWarningRowDescriptor
        else { return }
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        if let rowTag = formRow.tag, value = newValue as? NSNumber  where rowTag == Tags.Money.rawValue {
            cardTypeValidator.paymentAmount = Int(value)
        }
        
        //Show mpesa minimum payment amount worning label
        let paymenTypeValidationStatus = paymentTypeRowDescriptor.doValidation()
        if !paymenTypeValidationStatus.isValid && paymenTypeValidationStatus.msg == DonateViewController.mpesaPeymentAmountErrorMessage {
            paymentAmountWarningRowDescriptor.hidden = false
        } else {
            paymentAmountWarningRowDescriptor.hidden = true
        }
        
        //Enable or disable confirm button
        let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
        confirmRowDescriptor.disabled = hasErrors
        confirmRowDescriptor.cellConfig["backgroundColor"] = backgroundColor
        updateFormRow(confirmRowDescriptor)
        
    }
    
    //MARK: - Analytic tracking
    
    private func sendDonationEventToAnalytics(action action: String, label: String? = nil) {
        //Send tracking enevt
        var paymentTypeName = ""
        if let cardType = selectedCardType, cardName = CardItem.cardName(cardType) {
            paymentTypeName = cardName
        } else {
            paymentTypeName = NSLocalizedString("Can't get payment type")
        }
        
        let donationTypeName = AnalyticCategories.labelForDonationType(donationType)
        let paymentTypeLabel = label ?? paymentTypeName
        let paymentAmountNumber = NSNumber(integer: amount ?? 0)
        trackEventToAnalytics(donationTypeName, action: action, label: paymentTypeLabel, value: paymentAmountNumber)
    }
    
    private func sendScreenNameToAnalytics() {
       trackScreenToAnalytics(AnalyticsLabels.labelForDonationType(donationType))
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
    
    internal class CardTypeValidator: NSObject, XLFormValidatorProtocol {
        var paymentAmount = 0
        
        @objc func isValid(row: XLFormRowDescriptor!) -> XLFormValidationStatus {
            var msg = ""
            var status = false
            
            if let box: Box<CardItem> = row.value as? Box where box.value == .CreditDebitCard || (box.value == .MPesa && paymentAmount >= 10) {
                msg = NSLocalizedString("Selected value is valid")
                status = true
            } else if let box: Box<CardItem> = row.value as? Box where box.value == .MPesa && paymentAmount < 10 {
                msg = DonateViewController.mpesaPeymentAmountErrorMessage
                status = false
            } else {
                msg = NSLocalizedString("Selected value is invalid (empty)")
                status = false
            }
            return XLFormValidationStatus(msg: msg, status: status, rowDescriptor: row)
        }
    }
}