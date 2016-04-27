//
//  ProductOrderPaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 26/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class ProductOrderPaymentViewController: CommonPaymentViewController {
    
    internal var viewControllerToOpenOnComplete: UIViewController?
    internal var product: Product?
    
    // MARK: - Private ivars
    private var sectionsCount = 1
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerNib(UINib(nibName: String(PaymentOrderDescriptionCell.self), bundle: nil), forCellReuseIdentifier: String(PaymentOrderDescriptionCell.self))
    }
    
    // MARK: - Override parent implementation
    override func paymentDidSuccess() {
        super.paymentDidSuccess()
        sendPaymentEventToAnalytics(label: NSLocalizedString("Payment Completed"))
    }
    
    
    override func paymentDidFail(error: NSError) {
        super.paymentDidFail(error)
        sendPaymentEventToAnalytics(label: error.localizedDescription)
    }
    
    override func closeButtonTappedAfterSuccessPayment(sender: AnyObject) {
        if let viewController = viewControllerToOpenOnComplete {
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            super.closeButtonTappedAfterSuccessPayment(sender)
        }
    }
    
    private func pickUPAvaliabilityLabel() -> String? {
        guard let startDate = product?.startDate, endDate = product?.endData else { return nil }
        
        let availabilityRangeString = startDate.toDateString(endDate)
        return availabilityRangeString

    }
    
    //MARK: - Analytic tracking
    private func sendPaymentEventToAnalytics(label label: String) {
        let paymentAmountNumber = NSNumber(float: paymentSystem.item.totalAmount)
        trackEventToAnalytics(AnalyticCategories.product, action: AnalyticActios.paymentOutcome, label: label, value: paymentAmountNumber)
    }
    
}

//MARK: - UITableViewDataSource
extension ProductOrderPaymentViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PaymentOrderDescriptionCell.self), forIndexPath: indexPath) as! PaymentOrderDescriptionCell
            cell.totalLabel?.text = paymentSystem.item.totalAmountFofmattedString
            cell.quintityLabel?.text = String(paymentSystem.item.quantity)
            cell.itemNameLabel?.text = paymentSystem.item.itemName
            cell.iconImageView?.setImageFromURL(paymentSystem.item.imageURL)
            cell.pickUpAvailability = pickUPAvaliabilityLabel()
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension ProductOrderPaymentViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            let pickUPAvaliabilityHeight: CGFloat = pickUPAvaliabilityLabel() == nil ? 0 : 60
            return 175 + pickUPAvaliabilityHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
}
