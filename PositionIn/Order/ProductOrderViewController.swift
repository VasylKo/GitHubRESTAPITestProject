//
//  ProductOrderViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 20/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Braintree
import Box

class ProductOrderViewController: XLFormViewController {

    private enum Tags : String {
        case Header = "Header"
        case Avaliability = "Avaliability"
        case Quantity = "Quantity"
        case Total = "Total"
        case Payment = "Payment"
        case ProceedToPay = "ProceedToPay"

    }
    
    // MARK: - Private properties
    private weak var proceedToPayRowDescriptor: XLFormRowDescriptor?
    
    // MARK: - Internal properties
    internal var product: Product?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.tintColor = UIScheme.mainThemeColor
        //self.title = NSLocalizedString("Order")
        
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.marketItemPurchase)
    }
    
    // MARK: - Build XFForm
    func initializeForm() {
        guard let product = product else { return }
        
        let form = XLFormDescriptor(title: NSLocalizedString("Order", comment: "Order controller title"))
        
        //Product section
        let productSection = XLFormSectionDescriptor.formSection()
        productSection.title = ""
        form.addFormSection(productSection)
        
        //Product info  header row
        let orderHeaderRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Header.rawValue,
            rowType: XLFormRowDescriptorTypeOrderHeder)
        orderHeaderRow.cellConfigAtConfigure["name"] = product.name
        orderHeaderRow.cellConfigAtConfigure["projectIconURL"] = product.imageURL
        productSection.addFormRow(orderHeaderRow)
        
        //Avaliability row
        let avaliabilityRow = XLFormRowDescriptor(tag: Tags.Avaliability.rawValue, rowType: XLFormRowDescriptorTypeAvailabilityViewCell)
        setTitleStyleForRow(avaliabilityRow, text: NSLocalizedString("Pick-up avaliability"))
        setSubtitleStyleForRow(avaliabilityRow, text: "00-00-00 Pick-up avaliability")
        productSection.addFormRow(avaliabilityRow)
        
        
        //Quantity row
        let quantityRow = XLFormRowDescriptor(tag: Tags.Quantity.rawValue, rowType: XLFormRowDescriptorTypeStepCounter, title: NSLocalizedString("Quantity", comment: "New product: Quantity"))
        quantityRow.value = 0
        quantityRow.cellConfigAtConfigure["stepControl.minimumValue"] = 0
        quantityRow.cellConfigAtConfigure["stepControl.maximumValue"] = 100
        quantityRow.cellConfigAtConfigure["stepControl.stepValue"] = 1
        quantityRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.textColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.hidden"] = true
        quantityRow.cellStyle = .Subtitle
        //TODO: add formatter
        setTitleStyleForRow(quantityRow)
        setSubtitleStyleForRow(quantityRow, text: "0")
        quantityRow.onChangeBlock =  { [weak self] _, newValue, row in
            if let value = newValue as? NSNumber {
                let value = value.stringValue
                row.cellConfig.setObject(value, forKey: "detailTextLabel.text")
                self?.updateFormRow(row)
            }
        }
        quantityRow.addValidator(QuantityValidator())
        productSection.addFormRow(quantityRow)
        
        //Total price row
        let totalRow = XLFormRowDescriptor(tag: Tags.Total.rawValue, rowType: XLFormRowDescriptorTypeTotalViewCell)
        totalRow.cellConfigAtConfigure["priceText"] = String(product.price)
        productSection.addFormRow(totalRow)
        
        //Paument method section
        let paymentSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Payment"))
        form.addFormSection(paymentSection)
        
        //MPESA Bonga pin row
        let mpesaBongoPinRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeMPesaBongaPinView)
        mpesaBongoPinRow.hidden = true
        
        //Select payment method row
        let paymentRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Payment.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Select payment method", comment: "Payment"))
        paymentRow.required = true
        paymentRow.action.viewControllerClass = SelectPaymentMethodController.self
        paymentRow.valueTransformer = CardItemValueTrasformer.self
        paymentRow.value = nil
        paymentRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        paymentRow.onChangeBlock = { [weak self] oldValue, newValue, _ in
            if let box: Box<CardItem> = newValue as? Box {
                //self?.paymentType = CardItem.cardPayment(box.value)
                //self?.selectedCardType = box.value
                //self?.sendDonationEventToAnalytics(action: AnalyticActios.selectPaymentMethod)
                
                //Show M-Pesa additional info row
                mpesaBongoPinRow.hidden = box.value != .MPesa
                
            } else {
                //self?.paymentType = nil
                
            }
        }
        
        paymentSection.addFormRow(paymentRow)
        paymentSection.addFormRow(mpesaBongoPinRow)
        
        //ProceedToPay section
        let proceedToPaySection = XLFormSectionDescriptor.formSection()
        form.addFormSection(proceedToPaySection)
        
        let proceedToPayRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.ProceedToPay.rawValue,
        rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("Proceed to Pay"))
        proceedToPayRowDescriptor = proceedToPayRow
        proceedToPayRow.disabled = true
        proceedToPayRow.cellConfig["backgroundColor"] = UIScheme.disableActionColor
        proceedToPayRow.cellConfig["textLabel.color"] = UIColor.whiteColor()
        proceedToPayRow.cellConfig["textLabel.textAlignment"] =  NSTextAlignment.Center.rawValue
        
        /*
        proceedToPayRow.action.formBlock = { [weak self] row in
            self?.deselectFormRow(row)
            
            let validationErrors : Array<NSError> = self?.formValidationErrors() as! Array<NSError>
            if (validationErrors.count > 0){
                return
            }
            
            self?.sendDonationEventToAnalytics(action: AnalyticActios.proceedToPay)
            
            self?.performSegueWithIdentifier("Show\((self?.paymentType)!)", sender: self!)
            self?.setError(true, error: nil)
        }
*/
        
        proceedToPaySection.addFormRow(proceedToPayRow)
        
        proceedToPaySection.footerTitle = NSLocalizedString("By purchasing, you agree to Red Cross Terms of Service and Privacy Policy")
        
        self.form = form
    }
    
    // MARK: XLForm helper
    private func setTitleStyleForRow(row: XLFormRowDescriptor, text: String? = nil) {
        row.cellConfig.setObject(UIScheme.appRegularFontOfSize(15), forKey: "textLabel.font")
        row.cellConfig.setObject(UIColor.bt_colorFromHex("9C9C9C", alpha: 1.0), forKey: "textLabel.color")
        if let text = text {
           row.cellConfig.setObject(text, forKey: "textLabel.text")
        }
    }
    
    private func setSubtitleStyleForRow(row: XLFormRowDescriptor, text: String? = nil) {
        row.cellConfig.setObject(UIScheme.appRegularFontOfSize(17), forKey: "detailTextLabel.font")
        if let text = text {
            row.cellConfig.setObject(text, forKey: "detailTextLabel.text")
        }
    }
    
    // MARK: XLFormViewController
    private func checkFormFields() {
        guard let proceedToPayRowDescriptor = proceedToPayRowDescriptor else { return }
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        
        //Enable or disable confirm button
        let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
        proceedToPayRowDescriptor.disabled = hasErrors
        proceedToPayRowDescriptor.cellConfig["backgroundColor"] = backgroundColor
        updateFormRow(proceedToPayRowDescriptor)
    }
    
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        guard let proceedToPayRowDescriptor = proceedToPayRowDescriptor else { return }
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        
        //Enable or disable confirm button
        let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
        proceedToPayRowDescriptor.disabled = hasErrors
        proceedToPayRowDescriptor.cellConfig["backgroundColor"] = backgroundColor
        updateFormRow(proceedToPayRowDescriptor)
        
    }
    
    // MARK: - Override Table View methods
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let row = form.formRowAtIndex(indexPath) where row.tag == Tags.Quantity.rawValue else { return super.tableView(tableView, heightForRowAtIndexPath: indexPath) }
        
        return 50.0
    }
}

//MARK - Validators
extension ProductOrderViewController {
    
    internal class QuantityValidator: NSObject, XLFormValidatorProtocol {
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