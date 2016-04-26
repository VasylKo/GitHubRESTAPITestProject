//
//  BraintreePayment.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/24/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import Braintree
import BrightFutures

final class BraintreePaymentSystem: NSObject, PaymentSystem {
    // MARK: - Private ivar
    var item: PurchaseConvertible
    private var dropInViewController: BTDropInViewController?
    private let promise: Promise<Void, NSError>
    
    //Create simple error
    //TODO: Create logic to generate valid payment errors
    private lazy var paymentError: NSError = {
        let userInfo: [NSObject : AnyObject] = [
            NSLocalizedDescriptionKey: NSLocalizedString("Braintree Payment Error", comment: "Localized Braintree payment error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Unknown", comment: "Localized Braintree payment error reazon"),
            ]
        return NSError(domain: "com.bekitzur.payment", code: 100, userInfo: userInfo)
    }()
    private lazy var userCancelPaymentError: NSError = {
        let userInfo: [NSObject : AnyObject] = [
            NSLocalizedDescriptionKey: NSLocalizedString("User cancel payment", comment: "Localized Braintree payment error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("User did not entered credit card details", comment: "Localized Braintree payment error reazon"),
        ]
        return NSError(domain: "com.bekitzur.payment", code: 100, userInfo: userInfo)
    }()
    
    // MARK: - Init, PaymentSystem
    required init(item: PurchaseConvertible) {
        self.item = item
        promise = Promise<Void, NSError>()
    }
    
    func purchase() -> Future<Void, NSError> {
        api().getToken().onSuccess { [weak self] token in
            self?.initBraintree(clientToken: token)
        }.onFailure { [weak self] error in
            self?.promise.failure(error)
        }
        
        return promise.future
    }
    
    //MARK: - Brain Tree
    private func initBraintree(clientToken token: String) {
        
        let braintreeClient = BTAPIClient(authorization: token)
        let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
        self.dropInViewController = dropInViewController
        setUpProuctInfoBage(dropInViewController)
        dropInViewController.delegate = self
        
        //UI setup
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        navigationController.view.tintColor = UIScheme.mainThemeColor
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("userDidCancelPayment"))
        dropInViewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        dropInViewController.title = NSLocalizedString("Payment Method", comment: "braintree title")
        
        //Search for current VC to present dropInViewController
        var currentViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        while ((currentViewController?.presentedViewController) != nil) {
            currentViewController = currentViewController?.presentedViewController
        }
        
        guard let controller = currentViewController else { promise.failure(paymentError)
        return }
        controller.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func setUpProuctInfoBage(controller: BTDropInViewController) {
        
        //Fill product info
        let summaryFormat = NSLocalizedString("%@ %@", comment: "Order: Summary format")
        let callToActionTextFormat = NSLocalizedString("%@ - %@", comment: "Order: Summary format")
        controller.paymentRequest?.summaryTitle = item.itemName
        controller.paymentRequest?.displayAmount = item.totalAmountFofmattedString
        
        //Set up bage description
        switch item.purchaseType {
        case .Product:
            controller.paymentRequest?.summaryDescription = String(format: summaryFormat, NSLocalizedString("Quantity:"), String(item.quantity))
        case .Donation:
            controller.paymentRequest?.summaryDescription = NSLocalizedString("Donation")
        case .Membership:
            controller.paymentRequest?.summaryDescription = NSLocalizedString("Membership plan")
        case .Eplus:
            controller.paymentRequest?.summaryDescription = NSLocalizedString("Eplus plan")
        }
        
        controller.paymentRequest?.callToActionText = String(format: callToActionTextFormat, item.totalAmountFofmattedString, NSLocalizedString("Pay"))
        
    }
    
    //MARK: - Actions
    @IBAction func userDidCancelPayment() {
        dismissPaymentsController() { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.promise.failure(strongSelf.userCancelPaymentError)
        }
    }
    
    private func dismissPaymentsController(completion completion: (() -> ())?) {
        dropInViewController?.dismissViewControllerAnimated(true, completion: completion)
    }
    
    //MARK: - Purchase implementation
    private func purchaseDonation(withTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        let response = api().donateCheckoutBraintree(String(item.totalAmount), nonce: paymentMethodNonce.nonce, itemId: item.itemId)
        commonBrintreePaymentPesponseHandler(response)
    }
    
    private func purchaseMembership(withTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        let response = api().membershipCheckoutBraintree(String(item.totalAmount), nonce: paymentMethodNonce.nonce, membershipId: item.itemId ?? CRUDObjectInvalidId)
        commonBrintreePaymentPesponseHandler(response)
    }
    
    private func purchaseProduct(withTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        let response = api().productCheckoutBraintree(String(item.totalAmount), nonce: paymentMethodNonce.nonce, itemId: item.itemId ?? CRUDObjectInvalidId, quantity: NSNumber(integer: item.quantity))
        commonBrintreePaymentPesponseHandler(response)
    }
    
    private func commonBrintreePaymentPesponseHandler(response: Future<String, NSError>) {
        response.onSuccess
            { [weak self] err in
                guard let strongSelf = self else { return }
                if(err == "") {
                    strongSelf.dismissPaymentsController() {
                        strongSelf.promise.success()
                    }
                } else {
                    strongSelf.dismissPaymentsController() {
                        strongSelf.promise.failure(strongSelf.paymentError)
                    }
                }
                
            }.onFailure { [weak self] (error) in
                self?.promise.failure(error)
        }
    }
}

//MARK: - BTDropInViewControllerDelegate
extension BraintreePaymentSystem: BTDropInViewControllerDelegate {
    @objc func dropInViewController(viewController: BTDropInViewController,
                              didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        switch item.purchaseType {
        case .Donation:
            purchaseDonation(withTokenization: paymentMethodNonce)
        case .Membership, .Eplus:
            purchaseMembership(withTokenization: paymentMethodNonce)
        case .Product:
            purchaseProduct(withTokenization: paymentMethodNonce)
        }
        
    }
    
    @objc func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        userDidCancelPayment()
    }

}
