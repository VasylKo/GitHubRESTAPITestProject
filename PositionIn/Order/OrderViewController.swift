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
        quantityFormatter.numberStyle = .DecimalStyle
        if let product = self.product {
            itemNameLabel.text = product.name
            let url = product.photos?.first?.url
            let image = product.category?.productPlaceholderImage()
            itemImageView.setImageFromURL(url, placeholder: image)
        }
    }

    @IBAction func quantityStepperDidChange(sender: UIStepper) {
        quantityLabel.text = quantityString
    }
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var quantityStepper: UIStepper!
    @IBOutlet private weak var quantityLabel: UILabel!
    
    private let quantityFormatter = NSNumberFormatter()
    private let braintree = Braintree()
    
    private var quantityString: String {
        return quantityFormatter.stringFromNumber(NSNumber(double: round(quantityStepper.value))) ?? ""
    }
    
    @IBAction func didTapCheckout(sender: AnyObject) {
        let dropInViewController = braintree.dropInViewControllerWithDelegate(self)
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "userDidCancelPayment:")
        let summaryFormat =  NSLocalizedString("%@ %@", comment: "Order: Summary format")
        dropInViewController.summaryTitle = String(format: summaryFormat, quantityString, product?.name ?? "")
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func userDidCancelPayment(sender: AnyObject) {
        dismissPaymentsController()
    }
    
    private func dismissPaymentsController() {
        dismissViewControllerAnimated(true, completion: nil)
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