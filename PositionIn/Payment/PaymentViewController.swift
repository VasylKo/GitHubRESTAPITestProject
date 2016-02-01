//
//  PaymentScreen.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 07/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class PaymentViewController: XLFormViewController, PaymentReponseDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeForm()
        view.tintColor = UIScheme.mainThemeColor
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(1)
        self.view.addSubview(pageView)
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


    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
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
        paymentSection.addFormRow(paymentRow)
        
        let confirmDonation = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmDonation)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Confirm Payment", comment: "Payment"))
        
        confirmRow.action.formBlock = { [weak self]_ in
            let paymentController: BraintreePaymentViewController = BraintreePaymentViewController()
            paymentController.amount = self?.plan.price
            paymentController.productName = self?.plan.name
            paymentController.quantity = 1
            paymentController.delegate = self
            paymentController.delegate = self
            self?.navigationController?.pushViewController(paymentController, animated: true)
        }
        
        confirmDonation.addFormRow(confirmRow)
        
        self.form = form
    }
    
    //MARK: PaymentReponseDelegate
    
    func setError(hidden: Bool, error: String?) {
        self.sideBarController?.executeAction(SidebarViewController.defaultAction)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func paymentReponse(success: Bool, err: String?) {
        if(success) {
            setError(true, error: nil)
        } else {
            setError(false, error: err)
        }
    }
}
