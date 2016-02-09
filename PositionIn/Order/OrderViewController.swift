//
//  OrderViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import Braintree

class OrderViewController: UITableViewController, SelectPaymentMethodControllerDelegate {
    var product: Product?
    private var clientToken: String?
    private var finishedSuccessfully = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        api().getToken().onSuccess { [weak self] token in
            self?.clientToken = token
            self?.initializeBrainTree()
        }
        
        if let product = self.product {
            itemNameLabel.text = product.name
            let url = product.imageURL
            let image = product.category?.productPlaceholderImage()
            itemImageView.setImageFromURL(url, placeholder: image)


            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd yyyy, HH:mm"
            if let startDate = product.startDate,
            let endData = product.endData {
                let startDateString = dateFormatter.stringFromDate(startDate)
                
                dateFormatter.dateFormat = "HH:mm"
                let endDateString = dateFormatter.stringFromDate(endData)
                
                self.dateTimeLabel.text = "\(startDateString) to \(endDateString)"
            }
        }
        updateLabels()
    }

    @IBAction func quantityStepperDidChange(sender: UIStepper) {
        updateLabels()
    }

    private func updateLabels() {
        quantityLabel.text = quantityString
        if let price = product?.price {
            let subtotal: Float = price * Float(quantity)
            subtotalLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: subtotal))
            let tax: Float = 0
            taxLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: tax))
            let fee: Float = 0
            feeLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: fee))
            let total = subtotal + tax + fee
            totalLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: total))
        } else {
            subtotalLabel.text = nil
            taxLabel.text = nil
            feeLabel.text = nil
            totalLabel.text = nil
        }
    }
    
    @IBOutlet private weak var paymentMethodLabel: UILabel!
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var quantityStepper: UIStepper!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var taxLabel: UILabel!
    @IBOutlet private weak var subtotalLabel: UILabel!
    
    @IBOutlet private weak var dateTimeLabel: UILabel!

    lazy private var quantityFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()

    private var cardItem: CardItem?
    private var braintreeClient: BTAPIClient?

    private var quantity: Int {
        return Int(round(quantityStepper.value))
    }

    private var quantityString: String {
        return quantityFormatter.stringFromNumber(NSNumber(integer: quantity)) ?? ""
    }

    @IBAction func selectPaymentTouched(sender: AnyObject) {
        let controller: SelectPaymentMethodController = SelectPaymentMethodController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapCheckout(sender: AnyObject) {
        
        if let braintreeClient = braintreeClient,
        cardItem = cardItem {
            switch cardItem {
            case .MPesa:
                if let product = product {
                    let controller = MPesaPaymentCompleteViewController(quantity: quantity, product: product)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            case .CreditDebitCard:
                fallthrough
            case .PayPal:
                let dropInViewController = BTDropInViewController(APIClient: braintreeClient)
                dropInViewController.delegate = self
                
                dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "userDidCancelPayment:")
                dropInViewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
                dropInViewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.bt_colorWithBytesR(254,
                    g: 187,
                    b: 182)]
                dropInViewController.title = NSLocalizedString("Payment Method", comment: "braintree title")
                let summaryFormat = NSLocalizedString("%@ %@", comment: "Order: Summary format")
                dropInViewController.paymentRequest?.summaryTitle = String(format: summaryFormat, quantityString, product?.name ?? "")
                dropInViewController.paymentRequest?.displayAmount = totalLabel.text ?? ""
                dropInViewController.paymentRequest?.summaryDescription = product?.text
                dropInViewController.paymentRequest?.callToActionText = NSLocalizedString("Checkout", comment: "Order: Checkout")
                let navigationController = UINavigationController(rootViewController: dropInViewController)
                navigationController.view.tintColor = UIScheme.mainThemeColor
                presentViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func paymentMethodSelected(cardItem: CardItem) {
        self.cardItem = cardItem
        self.paymentMethodLabel.text = CardItem.cardName(cardItem)
    }

    @IBAction func userDidCancelPayment(sender: AnyObject) {
        dismissPaymentsController()
    }

    private func dismissPaymentsController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func initializeBrainTree() {
        if let clientToken = clientToken {
            self.braintreeClient = BTAPIClient(authorization: clientToken)
        }
    }
}


extension OrderViewController: BTDropInViewControllerDelegate {
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        //TODO: should refactor
        let amount = product?.price!
        
        api().productCheckoutBraintree(String(amount!), nonce: paymentMethodNonce.nonce,
            itemId: (product?.objectId)!, quantity: self.quantity).onSuccess
            { [weak self] err in
                if(err == "") {
                    self?.dismissPaymentsController()
                    self?.finishedSuccessfully = true
                    
                    let controller = MPesaPaymentCompleteViewController(quantity: self!.quantity, product: (self?.product!)!)
                    controller.showSuccess = true
                    self?.navigationController?.pushViewController(controller, animated: true)
                    
                    
                } else {
                    
                }
        }
        dismissPaymentsController()
    }

    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissPaymentsController()
    }
}