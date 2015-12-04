//
//  DonateViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class DonateViewController: XLFormViewController {
    
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
        
        let form = XLFormDescriptor(title: NSLocalizedString("Donate", comment: "Donate"))
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Project.rawValue,
            rowType: XLFormRowDescriptorTypeDonate)
        donateToSection.addFormRow(donateProjectRow)
        
        let donatationSection = XLFormSectionDescriptor.formSectionWithTitle("Donation Amount (KSH)")
        form.addFormSection(donatationSection)
        
        let donatationRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Money.rawValue,
            rowType: XLFormRowDescriptorTypeDecimal)
        donatationRow.cellConfigAtConfigure["textField.placeholder"] = "Set a donation"
        donatationRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        donatationSection.addFormRow(donatationRow)
        
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
            title: NSLocalizedString("Confirm Donation", comment: "Payment"))
        
        confirmRow.action.viewControllerStoryboardId = "DonateNotificationViewController";

        confirmDonation.addFormRow(confirmRow)

        self.form = form
    }
}