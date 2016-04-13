//
//  AmbulancePaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Box

class AmbulancePaymentViewController: XLFormViewController, PaymentReponseDelegate {
    
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : MembershipRouter
    private let plan : MembershipPlan
    private weak var confirmRowDescriptor: XLFormRowDescriptor?
    
    private enum Tags : String {
        case Money = "Money"
        case Payment = "Payment"
        case Confirm = "Confirm"
    }
    
    //MARK: Initializers
    
    init(router: MembershipRouter, plan: MembershipPlan) {
        self.router = router
        self.plan = plan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.ambulancePayment)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.pageView.sizeToFit()
        var frame: CGRect = self.pageView.frame
        frame.origin.x = 0
        frame.origin.y = self.view.frame.size.height - frame.size.height
        self.pageView.frame = frame
        
        self.view.tintColor = UIScheme.mainThemeColor
    }
    
    //MARK: Setup Interface
    
    func setupInterface() {
        self.title = "Payment"
        
        view.tintColor = UIScheme.mainThemeColor
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(1)
        self.view.addSubview(pageView)
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Payment", comment: "Ambulance view controller title"))
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypePayment)
        
        donateProjectRow.cellConfigAtConfigure["planString"] = plan.name
        donateProjectRow.cellConfigAtConfigure["planImage"] = UIImage(named : plan.membershipImageName)
        
        if let price = plan.price {
            donateProjectRow.cellConfigAtConfigure["totalString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
        }
        
        donateToSection.addFormRow(donateProjectRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        
        //MPESA Bonga pin row
        let mpesaBongoPinRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeMPesaBongaPinView)
        mpesaBongoPinRow.hidden = true
        
        //Select payment method row
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentRow.required = true
        paymentRow.onChangeBlock = { oldValue, newValue, _ in
            if let box: Box<CardItem> = newValue as? Box {
                //Show M-Pesa additional info row
                mpesaBongoPinRow.hidden = box.value != .MPesa
            }
        }
        
        paymentSection.addFormRow(paymentRow)
        paymentSection.addFormRow(mpesaBongoPinRow)
        
        let confirmDonation = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmDonation)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Proceed to Pay"))
        confirmRowDescriptor = confirmRow
        confirmRow.disabled = true
        confirmRow.cellConfig["backgroundColor"] = UIScheme.disableActionColor
        confirmRow.cellConfig["textLabel.textColor"] = UIColor.whiteColor()
        
        confirmRow.action.formBlock = { [weak self] row in
            
            
            self?.deselectFormRow(row)
            
            let validationErrors : Array<NSError> = self?.formValidationErrors() as! Array<NSError>
            if (validationErrors.count > 0){
                return
            }
            
            //MPesa
            if let cardItem: Box<CardItem> = paymentRow.value as? Box<CardItem> {
                self?.sendEventToAnalytics(cardItem: cardItem, action: AnalyticActios.proceedToPay)
                
                if cardItem.value == .MPesa {
                    self?.router.showMPesaConfirmPaymentViewController(from: self!, with: self!.plan)
                }
                else {
                    let paymentController: BraintreePaymentViewController = BraintreePaymentViewController()
                    paymentController.amount = self?.plan.price
                    paymentController.productName = self?.plan.name
                    paymentController.membershipId = self?.plan.objectId
                    paymentController.delegate = self
                    self?.navigationController?.pushViewController(paymentController, animated: true)
                }
            }
        }
        
        confirmDonation.addFormRow(confirmRow)
        
        self.form = form
    }
    
    //MARK: - Analytics
    private func sendEventToAnalytics(cardItem cardItem: Box<CardItem>, action: String) {
        let cardType = CardItem.cardName(cardItem.value) ?? NSLocalizedString("Can't get card type")
        let paymentAmount = NSNumber(integer: self.plan.price ?? 0)
        trackEventToAnalytics(AnalyticCategories.membership, action: action, label: cardType, value: paymentAmount)
    }
    
    //MARK: PaymentReponseDelegate
    
    func setError(hidden: Bool, error: String?) {
        self.router.showBraintreeConfirmPaymentViewController(from: self, with: self.plan, creditCardPaymentSuccess: hidden)
    }
    
    func paymentReponse(success: Bool, err: String?) {
        if(success) {
            setError(true, error: nil)
        } else {
            setError(false, error: err)
        }
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        //Send payment method selected to analytics
        if formRow.tag == Tags.Payment.rawValue, let cardItem: Box<CardItem> = newValue as? Box<CardItem> {
            sendEventToAnalytics(cardItem: cardItem, action: AnalyticActios.selectPaymentMethod)
        }
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        if let confirmRowDescriptor = confirmRowDescriptor {
            let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
            confirmRowDescriptor.disabled = hasErrors
            confirmRowDescriptor.cellConfig["backgroundColor"] = backgroundColor
            updateFormRow(confirmRowDescriptor)
        }
    }
}

