//
// Created by Max Stoliar on 1/10/16.
// Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit
import Braintree

class BraintreePaymentViewController : UIViewController, BTDropInViewControllerDelegate, PaymentProtocol {
    private var braintreeClient: BTAPIClient?
    private var clientToken: String?
    private var dropInVc : BTDropInViewController?
    
    var amount: Int?
    var quantity: Int?
    var productName: String?
    var membershipId: String?
    var itemId: String?
    var product: Product?
    var delegate: PaymentReponseDelegate?
    
    override func viewDidLoad() {
        api().getToken().onSuccess { [weak self] token in
            if let strongSelf = self {
                strongSelf.clientToken = token
                strongSelf.initBraintree()
            }
        }
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics("BraintreePayment")
    }
    
    @IBAction func userDidCancelPayment() {
        dismissPaymentsController(false, err:nil)
    }
    
    private func dismissPaymentsController(success: Bool, err: String?) {
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.paymentReponse(success,err:err)
    }
    
    private func initBraintree() {
        if let clientToken = clientToken {
            
            self.braintreeClient = BTAPIClient(authorization: clientToken)
            
            let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
            dropInViewController.delegate = self
            
            dropInViewController.title = NSLocalizedString("Payment Method", comment: "braintree title")
            let summaryFormat = NSLocalizedString("%@ %@", comment: "Order: Summary format")
            dropInViewController.paymentRequest?.summaryTitle = productName
            if let quantity = self.quantity {
                dropInViewController.paymentRequest?.summaryDescription = String(format: summaryFormat, "Quantity:", String(quantity))
            }
            
            if let amount = self.amount {
                let displayAmount = "\(AppConfiguration().currencySymbol) \(amount)"
                dropInViewController.paymentRequest?.displayAmount = displayAmount
            }

            dropInViewController.paymentRequest?.callToActionText = NSLocalizedString("Checkout", comment: "Order: Checkout")
            
            self.view.addSubview(dropInViewController.view)
            
            self.dropInVc = dropInViewController
        }
    }
    
    func dropInViewController(viewController: BTDropInViewController,
        didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        //TODO: should check unwrapping
            if let membershipId = self.membershipId {
                api().membershipCheckoutBraintree(String(amount!), nonce: paymentMethodNonce.nonce,
                    membershipId: membershipId).onSuccess
                    { [weak self] err in
                        if let strongSelf = self {
                            if(err == "") {
                                strongSelf.dismissPaymentsController(true, err: nil)
                            } else {
                                strongSelf.dismissPaymentsController(false, err: err)
                            }
                        }
                }
            }
            else {
                api().donateCheckoutBraintree(String(amount!), nonce: paymentMethodNonce.nonce, itemId: self.itemId).onSuccess
                    { [weak self] err in
                        if let strongSelf = self {
                            if(err == "") {
                                strongSelf.dismissPaymentsController(true, err: nil)
                            } else {
                                strongSelf.dismissPaymentsController(false, err: err)
                            }
                        }
                }
            }
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissPaymentsController(true, err: nil)
    }
}
