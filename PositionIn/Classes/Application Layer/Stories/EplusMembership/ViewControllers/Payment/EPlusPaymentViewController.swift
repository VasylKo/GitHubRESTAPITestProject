//
//  EplusPaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Box

class EPlusPaymentViewController: XLFormViewController, PaymentReponseDelegate {
    
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : EPlusMembershipRouter
    private let plan : EPlusMembershipPlan
    private weak var confirmRowDescriptor: XLFormRowDescriptor?
    
    private enum Tags : String {
        case Plan = "Plan"
        case Payment = "Payment"
        case MpesaBomgaPin = "MpesaPin"
        case Buy = "Buy"
    }
    
    //MARK: Initializers
    
    init(router: EPlusMembershipRouter, plan: EPlusMembershipPlan) {
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
        
        //Plan header section
        let planHeaderSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(planHeaderSection)
        
        //Plan description row
        let planDescriptionRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Plan.rawValue,
            rowType: XLFormRowDescriptorTypeAmbulancePayment)
    
        planDescriptionRow.cellConfigAtConfigure["planString"] = plan.name
        planDescriptionRow.cellConfigAtConfigure["planImage"] = UIImage(named : plan.membershipImageName)
        planDescriptionRow.cellConfigAtConfigure["totalString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                plan.price ?? 0)) ?? ""
        
        planHeaderSection.addFormRow(planDescriptionRow)
        
        
        //Payment type section
        let selectPaymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(selectPaymentSection)
        
        
        //MPESA Bonga pin row
        let mpesaBongoPinRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.MpesaBomgaPin.rawValue, rowType: XLFormRowDescriptorTypeMPesaBongaPinView)
        mpesaBongoPinRow.hidden = true
        
        //Select payment method row
        let selectPaymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        selectPaymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        selectPaymentRow.valueTransformer = CardItemValueTrasformer.self
        selectPaymentRow.value = nil
        selectPaymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        selectPaymentRow.required = true
        selectPaymentRow.onChangeBlock = { [weak self] oldValue, newValue, _ in
            if let box: Box<CardItem> = newValue as? Box {
                //Send payment method selected to analytics
                self?.sendEventToAnalytics(cardItem: box.value, action: AnalyticActios.selectPaymentMethod)
                
                //Show M-Pesa additional info row
                mpesaBongoPinRow.hidden = box.value != .MPesa
            }
        }
        
        selectPaymentSection.addFormRow(selectPaymentRow)
        selectPaymentSection.addFormRow(mpesaBongoPinRow)
        
        //Proceed to Pay section
        let confirmPaymentSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmPaymentSection)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Buy.rawValue,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Proceed to Pay"))
        confirmRowDescriptor = confirmRow
        confirmRow.disabled = true
        confirmRow.cellConfig["backgroundColor"] = UIScheme.disableActionColor
        confirmRow.cellConfig["textLabel.textColor"] = UIColor.whiteColor()
        
        confirmRow.action.formBlock = { [weak self] row in
            
            
            self?.deselectFormRow(row)
            
            //Validate all entered fileds
            let validationErrors : Array<NSError> = self?.formValidationErrors() as! Array<NSError>
            if (validationErrors.count > 0){
                return
            }
            
            guard let card = self?.selectPaymentRowValue() else { return }
            
            self?.sendEventToAnalytics(cardItem: card, action: AnalyticActios.proceedToPay)
            self?.proceedPaymentWithCard(card)
        }
        
        confirmPaymentSection.addFormRow(confirmRow)
        
        self.form = form
    }
    
    //MARK: - XLForm helper
    private func selectPaymentRowValue() -> CardItem? {
        guard   let selectPaymentRow = form.formRowWithTag(Tags.Payment.rawValue),
                let cardItem: Box<CardItem> = selectPaymentRow.value as? Box<CardItem>,
                let card: CardItem = cardItem.value
        else {
            return nil
        }
        
        return card
    }
    
    //MARK: - Payment
    private func proceedPaymentWithCard(card: CardItem) {
        
        switch card {
        case .MPesa:
            //TODO: add route to confirm payment controller
            //router.showMPesaConfirmPaymentViewController(from: self, with: self.plan)
            navigationController?.pushViewController(EplusConfirmPaymentViewController(router: router, plan: self.plan, card: card), animated: true)
            
        case .CreditDebitCard:
            let paymentController: BraintreePaymentViewController = BraintreePaymentViewController()
            paymentController.amount = plan.price
            paymentController.productName = plan.name
            paymentController.membershipId = plan.objectId
            paymentController.delegate = self
            navigationController?.pushViewController(paymentController, animated: true)
        }
    }
    
    
    //MARK: - Analytics
    private func sendEventToAnalytics(cardItem cardItem: CardItem, action: String) {
        let cardType = CardItem.cardName(cardItem) ?? NSLocalizedString("Can't get card type")
        let paymentAmount = NSNumber(integer: self.plan.price ?? 0)
        trackEventToAnalytics(AnalyticCategories.membership, action: action, label: cardType, value: paymentAmount)
    }
    
    //MARK: PaymentReponseDelegate
    
    func setError(isSuccess: Bool, error: String?) {
        //TODO: add route to confirm payment controller
        //self.router.showBraintreeConfirmPaymentViewController(from: self, with: self.plan, creditCardPaymentSuccess: hidden)
        
        guard let card = selectPaymentRowValue() else { return }
        navigationController?.pushViewController(EplusConfirmPaymentViewController(router: router, plan: self.plan, card: card, isSuccess: isSuccess), animated: true)
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

