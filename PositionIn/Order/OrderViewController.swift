//
//  OrderViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import Braintree

class OrderViewController: UITableViewController {
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let product = self.product {
            itemNameLabel.text = product.name
            let url = product.photos?.first?.url
            let image = product.category?.productPlaceholderImage()
            itemImageView.setImageFromURL(url, placeholder: image)
        }
        initializeBranTree()
    }

    @IBAction func quantityStepperDidChange(sender: UIStepper) {
        quantityLabel.text = quantityString
        if let price = product?.price {
            let subtotal: Float = price * Float(quantity)
            subtotalLabel.text = currencyFormatter.stringFromNumber(NSNumber(float: subtotal))
            let tax = subtotal * 0.027
            taxLabel.text = currencyFormatter.stringFromNumber(NSNumber(float: tax))
            let fee: Float = 0.40
            feeLabel.text = currencyFormatter.stringFromNumber(NSNumber(float: fee))
            let total = subtotal + tax + fee
            totalLabel.text = currencyFormatter.stringFromNumber(NSNumber(float: total))
        }
        
    }
    
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var quantityStepper: UIStepper!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    lazy private var quantityFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    lazy private var currencyFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }()
    
    private var braintree: Braintree?
    
    private var quantity: Int {
        return Int(round(quantityStepper.value))
    }
    
    private var quantityString: String {
        return quantityFormatter.stringFromNumber(NSNumber(integer: quantity)) ?? ""
    }
    
    
    @IBAction func didTapCheckout(sender: AnyObject) {
        if let dropInViewController = braintree?.dropInViewControllerWithDelegate(self) {
            dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "userDidCancelPayment:")
            let summaryFormat =  NSLocalizedString("%@ %@", comment: "Order: Summary format")
            dropInViewController.summaryTitle = String(format: summaryFormat, quantityString, product?.name ?? "")
            dropInViewController.displayAmount = totalLabel.text
            dropInViewController.summaryDescription = product?.text
            dropInViewController.callToActionText = NSLocalizedString("Checkout", comment: "Order: Checkout")
            let navigationController = UINavigationController(rootViewController: dropInViewController)
            navigationController.view.tintColor = UIScheme.mainThemeColor
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func userDidCancelPayment(sender: AnyObject) {
        dismissPaymentsController()
    }
    
    private func dismissPaymentsController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func initializeBranTree() {
        let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmYzE1N2VmZGM0Yzc2ZWZlOTA4ZmQ0ZjQ4ZThkMjY2MGM4MGY0ZDQ0NGQyZDdlMWQwNzYxNjA4ZDQ3OWFmMGI5fGNyZWF0ZWRfYXQ9MjAxNS0wOS0wNlQyMTo0NDowMS43NTk5NDQ1MzArMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJhY21ld2lkZ2V0c2x0ZHNhbmRib3giLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifSwiY29pbmJhc2VFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRJZCI6IjM0OHBrOWNnZjNiZ3l3MmIiLCJ2ZW5tbyI6Im9mZiJ9"
        self.braintree = Braintree(clientToken: clientToken)
//        if let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token") {
//            var clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
//            clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
//            NSURLConnection.sendAsynchronousRequest(clientTokenRequest, queue: NSOperationQueue.mainQueue()) {
//                (response, data, error) in
//                if  let data = data,
//                    let clientToken = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
//                        self.braintree = Braintree(clientToken: clientToken)
//                }
//            }
//        }
    }
}


extension OrderViewController: BTDropInViewControllerDelegate {
    /// Informs the delegate when the user has successfully provided a payment method.
    ///
    /// Upon receiving this message, you should dismiss Drop In.
    ///
    /// @param viewController The Drop In view controller informing its delegate of success
    /// @param paymentMethod The selected (and possibly newly created) payment method.
    func dropInViewController(viewController: BTDropInViewController!, didSucceedWithPaymentMethod paymentMethod: BTPaymentMethod!) {
        dismissPaymentsController()
    }
    
    /// Informs the delegate when the user has decided to cancel out of the Drop In payment form.
    ///
    /// Drop In handles its own error cases, so this cancelation is user initiated and
    /// irreversable. Upon receiving this message, you should dismiss Drop In.
    ///
    /// @param viewController The Drop In view controller informing its delegate of failure.
    /// @param error An error that describes the failure.
    func dropInViewControllerDidCancel(viewController: BTDropInViewController!) {
        dismissPaymentsController()
    }
   
}