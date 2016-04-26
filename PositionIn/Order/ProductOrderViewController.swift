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
    private var braintreeClient: BTAPIClient?
    
    // MARK: - Internal properties
    internal var product: Product?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.marketItemPurchase)
    }
    
    // MARK: - Formatters
    lazy private var quantityFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    
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
        if let startDate = product.startDate, let endDate = product.endData {
            let avaliabilityRow = XLFormRowDescriptor(tag: Tags.Avaliability.rawValue, rowType: XLFormRowDescriptorTypeAvailabilityViewCell)
            setTitleStyleForRow(avaliabilityRow, text: NSLocalizedString("Pick-up avaliability"))

            let availabilityRangeString = startDate.toDateString(endDate)
            setSubtitleStyleForRow(avaliabilityRow, text: availabilityRangeString)
        
            productSection.addFormRow(avaliabilityRow)
        }
        

        //Quantity row
        let quantityRow = XLFormRowDescriptor(tag: Tags.Quantity.rawValue, rowType: XLFormRowDescriptorTypeStepCounter, title: NSLocalizedString("Quantity", comment: "New product: Quantity"))
        quantityRow.value = 0
        quantityRow.cellConfigAtConfigure["stepControl.minimumValue"] = 0
        quantityRow.cellConfigAtConfigure["stepControl.maximumValue"] = product.quantity ?? 1
        quantityRow.cellConfigAtConfigure["stepControl.stepValue"] = 1
        quantityRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.textColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.hidden"] = true
        quantityRow.cellStyle = .Subtitle
        //TODO: add formatter
        setTitleStyleForRow(quantityRow)
        setSubtitleStyleForRow(quantityRow)
        quantityRow.onChangeBlock =  { [weak self] _, newValue, row in
            guard let value = newValue as? NSNumber, strongSelf = self else { return }
            strongSelf.setQuantuty(value)
        }
        
        quantityRow.addValidator(QuantityValidator())
        productSection.addFormRow(quantityRow)
        
        //Total price row
        let totalRow = XLFormRowDescriptor(tag: Tags.Total.rawValue, rowType: XLFormRowDescriptorTypeTotalViewCell)
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
        paymentRow.onChangeBlock = { oldValue, newValue, _ in
            guard let box: Box<CardItem> = newValue as? Box else { return }
            //Show M-Pesa additional info row
            mpesaBongoPinRow.hidden = box.value != .MPesa
        }
        
        paymentSection.addFormRow(paymentRow)
        paymentSection.addFormRow(mpesaBongoPinRow)
        
        //ProceedToPay section
        let proceedToPaySection = XLFormSectionDescriptor.formSection()
        form.addFormSection(proceedToPaySection)
        
        let proceedToPayRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.ProceedToPay.rawValue,
        rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("Proceed to Pay"))
        //proceedToPayRowDescriptor = proceedToPayRow
        proceedToPayRow.disabled = true
        proceedToPayRow.cellConfig["backgroundColor"] = UIScheme.disableActionColor
        proceedToPayRow.cellConfig["textLabel.color"] = UIColor.whiteColor()
        proceedToPayRow.cellConfig["textLabel.textAlignment"] =  NSTextAlignment.Center.rawValue
        proceedToPayRow.action.formBlock = { [weak self] row in
            guard let strongSelf = self else { return }
            
            strongSelf.deselectFormRow(row)
            
            //Payment flow
            let paymentSystem = PaymentSystemProvider.paymentSystemWithItem(strongSelf)
            let paymentController = ProductOrderPaymentViewController(paymentSystem: paymentSystem)
            //Get alias to previous View Controller
            if let viewControllers = strongSelf.navigationController?.viewControllers {
                paymentController.viewControllerToOpenOnComplete = viewControllers[viewControllers.count - 2]
            }
            paymentController.product = strongSelf.product
            strongSelf.navigationController?.pushViewController(paymentController, animated: true)

        }

        
        proceedToPaySection.addFormRow(proceedToPayRow)
        
        proceedToPaySection.footerTitle = NSLocalizedString("By purchasing, you agree to Red Cross Terms of Service and Privacy Policy")
        
        self.form = form
        
        //Set initial values
        setQuantuty(0)
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
    
    private func quantitySelected() -> Int? {
        guard let quantityRow = form.formRowWithTag(Tags.Quantity.rawValue), value = quantityRow.value as? NSNumber else { return nil }
        
        return value.integerValue
    }
    
    private func cardPaymentTypeSelecred() -> CardItem {
        guard let paymentTypeRow = form.formRowWithTag(Tags.Payment.rawValue), box: Box<CardItem> = paymentTypeRow.value as? Box else { return .CreditDebitCard }
        
        return box.value
    }
    
    private func setQuantuty(quantity: NSNumber) {
        guard let quantutyRow = form.formRowWithTag(Tags.Quantity.rawValue), let product = product else { return }
        
        //Update quantity
        let quantityString = (quantityFormatter.stringFromNumber(quantity) ?? "") +
            NSLocalizedString(" (Out of \(product.quantity ?? 0) available)")
        quantutyRow.cellConfig.setObject(quantityString, forKey: "detailTextLabel.text")
        updateFormRow(quantutyRow)
        
        //Update total price
        let total = (product.price ?? 0) * quantity.floatValue
        setTotalPrice(total)
    }
    
    private func setTotalPrice(price: Float) -> String {
        guard let totalPriceRow = form.formRowWithTag(Tags.Total.rawValue) else { return "" }
        let totalPriceLabel = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: price)) ?? ""
        totalPriceRow.cellConfig.setObject(totalPriceLabel, forKey: "priceText")
        updateFormRow(totalPriceRow)
        return totalPriceLabel
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        guard let proceedToPayRow = form.formRowWithTag(Tags.ProceedToPay.rawValue) else { return }
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        //Enable or disable confirm button
        let backgroundColor = hasErrors ? UIScheme.disableActionColor : UIScheme.enableActionColor
        proceedToPayRow.disabled = hasErrors
        proceedToPayRow.cellConfig["backgroundColor"] = backgroundColor
        updateFormRow(proceedToPayRow)
        
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

//MARK: - PurchaseConvertible
extension ProductOrderViewController: PurchaseConvertible {
    var price: NSNumber {
        return NSNumber(float: product?.price ?? 0)
    }
    
    var itemId: String? {
        return product?.objectId
    }
    
    var quantity: Int {
        return quantitySelected() ?? 1
    }
    
    var itemName: String {
        return product?.name ?? ""
    }
    
    var purchaseType: PurchaseType {
        return .Product
    }
    
    var paymentTypes: CardItem {
        return cardPaymentTypeSelecred()
    }
    
    var imageURL: NSURL? {
        return product?.imageURL
    }
}