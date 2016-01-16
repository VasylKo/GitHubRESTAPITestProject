//
// Created by Max Stoliar on 1/10/16.
// Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit
import Braintree

class BraintreePaymentViewController : UIViewController, BTDropInViewControllerDelegate, PaymentProtocol {
    private var braintreeClient: BTAPIClient?
    private var clientToken = ""
    private var dropInVc : BTDropInViewController?
    
    var amount: Int?
    var quantity: Int?
    var productName: String?
    var delegate: PaymentReponseDelegate?
    
    override func viewDidLoad() {
        api().getToken().onSuccess { [weak self] token in
            if let strongSelf = self {
                strongSelf.clientToken = token
                strongSelf.initBraintree()
            }
        }
    }
    
    @IBAction func userDidCancelPayment() {
        dismissPaymentsController(false, err:nil)
    }
    
    private func dismissPaymentsController(success: Bool, err: String?) {
        delegate?.paymentReponse(success,err:err)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func initBraintree() {
        self.braintreeClient = BTAPIClient(authorization: clientToken)
        
        let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
        dropInViewController.delegate = self
        
        dropInViewController.title = NSLocalizedString("Payment Method", comment: "braintree title")
        let summaryFormat = NSLocalizedString("%@ %@", comment: "Order: Summary format")
        dropInViewController.paymentRequest?.summaryTitle = productName
        dropInViewController.paymentRequest?.displayAmount = "\(amount!) KSH"
        dropInViewController.paymentRequest?.summaryDescription = String(format: summaryFormat, "Quantity:", String(quantity!))
        dropInViewController.paymentRequest?.callToActionText = NSLocalizedString("Checkout", comment: "Order: Checkout")
        
        self.view.addSubview(dropInViewController.view)
        
        self.dropInVc = dropInViewController
    }
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        api().checkoutBraintree(String(amount!), nonce: paymentMethodNonce.nonce).onSuccess { [weak self] err in
            if let strongSelf = self {
                if(err == "") {
                    strongSelf.dismissPaymentsController(true, err: nil)
                } else {
                    strongSelf.dismissPaymentsController(false, err: err)
                }
            }
        }
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissPaymentsController(true, err: nil)
    }
}