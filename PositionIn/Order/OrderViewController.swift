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
    // MARK: - IBOutlets
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var proceedToPayButton: UIButton!
    
    // MARK: - Internal properties
    internal var product: Product?
    
    // MARK: - Private properties
    private var clientToken: String?
    private var finishedSuccessfully = false
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
        return (quantityFormatter.stringFromNumber(NSNumber(integer: quantity)) ?? "") +
            NSLocalizedString(" (Out of \(self.product?.quantity ?? 0) available)")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api().getToken().onSuccess { [weak self] token in
            self?.clientToken = token
            self?.initializeBrainTree()
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if let product = self.product {
            self.quantityStepper.maximumValue = Double(product.quantity ?? 1)
            
            itemNameLabel.text = product.name
            let url = product.imageURL
            let image = UIImage(named: "market_img_default")
            itemImageView.setImageFromURL(url, placeholder: image)


            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd yyyy, HH:mm"
            if let startDate = product.startDate,
            let endDate = product.endData {
                let startDateString = dateFormatter.stringFromDate(startDate)
                let endDateString = dateFormatter.stringFromDate(endDate)
                self.dateTimeLabel.text = "\(startDateString) to \(endDateString)"
            }
        }
        updateLabels()
    }

    // MARK: - Private functions
    private func updateLabels() {
        quantityLabel.text = quantityString
        if let price = product?.price {
            let total = price * Float(quantity)
            totalLabel.text = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: total))
        } else {
            totalLabel.text = nil
        }
    }
    
    private func updateStateOfActionButton() {
        var enableAction = quantity > 0
        enableAction = enableAction && cardItem != nil
        
        let actionBGColor = enableAction ? UIScheme.enableActionColor : UIScheme.disableActionColor
        proceedToPayButton.backgroundColor = actionBGColor
        proceedToPayButton.enabled = enableAction
    }
    
    private func dismissPaymentsController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func initializeBrainTree() {
        if let clientToken = clientToken {
            self.braintreeClient = BTAPIClient(authorization: clientToken)
        }
    }
    
    // MARK: - Actions
    @IBAction func quantityStepperDidChange(sender: UIStepper) {
        updateLabels()
        updateStateOfActionButton()
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
        updateStateOfActionButton()
    }

    @IBAction func userDidCancelPayment(sender: AnyObject) {
        dismissPaymentsController()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        // hide availability date cell
        if indexPath.section == 0 && indexPath.row == 1 && self.product?.startDate == nil && self.product?.endData == nil {
            return 0.0
        }
        return height
    }
}

// MARK: - BTDropInViewControllerDelegate
extension OrderViewController: BTDropInViewControllerDelegate {
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        if let product = product {
            if let price = product.price {
                
                let priceWitAmount = price * Float(self.quantity)
                
                api().productCheckoutBraintree(String(priceWitAmount), nonce: paymentMethodNonce.nonce,
                    itemId: product.objectId, quantity: self.quantity).onSuccess
                    { [weak self] err in
                        if(err == "") {
                            self?.dismissPaymentsController()
                            self?.finishedSuccessfully = true
                            
                            let controller = MPesaPaymentCompleteViewController(quantity: self!.quantity, product: (self?.product!)!)
                            controller.showSuccess = true
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                }
            }
        }
        dismissPaymentsController()
    }

    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissPaymentsController()
    }
}