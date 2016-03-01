//
//  PaymentScreen.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 07/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Box

class MembershipPaymentViewController: XLFormViewController, PaymentReponseDelegate {
    
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : MembershipRouter
    private let plan : MembershipPlan
    
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

    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func setupInterface() {
        self.title = "Payment"
        
        view.tintColor = UIScheme.mainThemeColor
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(1)
        self.view.addSubview(pageView)
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Payment", comment: "Donate"))
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypePayment)
        
        donateProjectRow.cellConfigAtConfigure["planString"] = plan.name
        donateProjectRow.cellConfigAtConfigure["planImage"] = UIImage(named : plan.membershipImageName)
        
        if let price = plan.price {
            donateProjectRow.cellConfigAtConfigure["priceString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
            donateProjectRow.cellConfigAtConfigure["totalString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
        }
        
        donateToSection.addFormRow(donateProjectRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentRow.required = true
        paymentSection.addFormRow(paymentRow)
        
        let confirmDonation = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmDonation)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Proceed to Pay"))
        confirmRow.cellConfig["backgroundColor"] = UIScheme.mainThemeColor
        confirmRow.cellConfig["textLabel.textColor"] = UIColor.whiteColor()
        
        confirmRow.action.formBlock = { [weak self] row in
            
            self?.deselectFormRow(row)
            
            let validationErrors : Array<NSError> = self?.formValidationErrors() as! Array<NSError>
            if (validationErrors.count > 0){
                self?.showFormValidationError(validationErrors.first)
                return
            }
            
            //MPesa
            if let cardItem: Box<CardItem> = paymentRow.value as? Box<CardItem> {
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
    
    //MARK: PaymentReponseDelegate
    
    func setError(hidden: Bool, error: String?) {
        self.router.showMemberDetailsViewController(from: self)
    }
    
    func paymentReponse(success: Bool, err: String?) {
        if(success) {
            setError(true, error: nil)
        } else {
            setError(false, error: err)
        }
    }
}
