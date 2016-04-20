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
        
        //Quantity row
        let quantityRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Quantity.rawValue,
            rowType: XLFormRowDescriptorTypeQuantityViewCell)
        
        /*
        quantityRow.value = 0
        quantityRow.cellConfigAtConfigure["stepControl.minimumValue"] = 0
        quantityRow.cellConfigAtConfigure["stepControl.maximumValue"] = 100
        quantityRow.cellConfigAtConfigure["stepControl.stepValue"] = 1
        quantityRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.textColor"] = UIScheme.mainThemeColor
        //quantityRow.cellConfigAtConfigure["currentStepValue.hidden"] = true
        //quantityRow.cellConfigAtConfigure["subtitle"] = "ddf"
        quantityRow.cellConfig.setObject("AppleSDGothicNeo-Regular", forKey: "detailTextLabel.text")
*/
        productSection.addFormRow(quantityRow)
        
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
    
    // MARK: - Override Table View methods
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1
        }
        
        return UITableViewAutomaticDimension
    }
}

extension ProductOrderViewController {
    /*
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
*/
}