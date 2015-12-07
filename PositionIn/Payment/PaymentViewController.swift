//
//  PaymentScreen.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 07/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class PaymentViewController: XLFormViewController {
    
    var corporatePlan: CorporatePlans? {
        didSet{
            self.initializeForm()
        }
    }
    var individualPlan: IndividualPlans? {
        didSet{
            self.initializeForm()
        }
    }
    
    private enum Tags : String {
        case Project = "Project"
        case Money = "Money"
        case Payment = "Payment"
        case Confirm = "Confirm"
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
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Project.rawValue,
            rowType: XLFormRowDescriptorTypePayment)
        if let corporatePlan = self.corporatePlan {
            if let price =  CorporatePlans.price(corporatePlan) {
                let priceString = "KES \(price)"
                donateProjectRow.cellConfigAtConfigure["priceString"] = priceString
                let totalString = "KES \(price + 45.0)"
                donateProjectRow.cellConfigAtConfigure["totalString"] = totalString
            }
            if let title = CorporatePlans.title(corporatePlan) {
                donateProjectRow.cellConfigAtConfigure["planString"] = title
            }
            if let image = CorporatePlans.corporateIconImage(corporatePlan) {
                donateProjectRow.cellConfigAtConfigure["planImage"] = image
            }
        } else if let individualPlan = self.individualPlan {
            if let price =  IndividualPlans.price(individualPlan) {
                let priceString = "KES \(price)"
                donateProjectRow.cellConfigAtConfigure["priceString"] = priceString
                let totalString = "KES \(price + 45.0)"
                donateProjectRow.cellConfigAtConfigure["totalString"] = totalString
            }
            if let title = IndividualPlans.title(individualPlan) {
                donateProjectRow.cellConfigAtConfigure["planString"] = title
            }
            if let image = IndividualPlans.individualIconImage(individualPlan) {
                donateProjectRow.cellConfigAtConfigure["planImage"] = image
            }
        }
        donateToSection.addFormRow(donateProjectRow)
        
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle("Payment")
        form.addFormSection(paymentSection)
        
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentSection.addFormRow(paymentRow)
        
        let confirmDonation = XLFormSectionDescriptor.formSection()
        form.addFormSection(confirmDonation)
        
        let confirmRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Confirm.rawValue,
            rowType: XLFormRowDescriptorTypeButton,
            title: NSLocalizedString("Confirm Payment", comment: "Payment"))
        
        confirmRow.action.formBlock = { [weak self]_ in
            self?.sideBarController?.executeAction(SidebarViewController.defaultAction)
            self?.dismissViewControllerAnimated(true, completion: nil)
            self?.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        confirmDonation.addFormRow(confirmRow)
        
        self.form = form
    }
}
