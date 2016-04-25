//
//  DonatePaymentController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/24/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class DonatePaymentController: CommonPaymentViewController {
    internal var viewControllerToOpenOnComplete: UIViewController?
    var donationType: DonateViewController.DonationType = .Donation
    
    private var sectionsCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.registerNib(UINib(nibName: String(DonateCell.self), bundle: nil), forCellReuseIdentifier: String(DonateCell.self))
        tableView?.registerNib(UINib(nibName: String(TotalCell.self), bundle: nil), forCellReuseIdentifier: String(TotalCell.self))
        
    }
    
    //MARK: - Override base class behaviour
    override func paymentDidSuccess() {
        super.paymentDidSuccess()
        sendDonationEventToAnalytics(action: AnalyticActios.paymentOutcome, label: NSLocalizedString("Payment Completed"))
    }
    
    override func paymentDidFail(error: NSError) {
        super.paymentDidFail(error)
        sendDonationEventToAnalytics(action: AnalyticActios.paymentOutcome, label: error.localizedDescription)
    }
    
    override func closeButtonTappedAfterSuccessPayment(sender: AnyObject) {
        if let viewController = viewControllerToOpenOnComplete {
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            sideBarController?.executeAction(SidebarViewController.defaultAction)
        }
    }

    //MARK: - Analytic tracking
    
    private func sendDonationEventToAnalytics(action action: String, label: String) {
        let donationTypeName = AnalyticCategories.labelForDonationType(donationType)
        let paymentAmountNumber = NSNumber(float: paymentSystem.item.totalAmount)
        trackEventToAnalytics(donationTypeName, action: action, label: label, value: paymentAmountNumber)
    }
    
}

//MARK: - Override UITableViewDataSource
extension DonatePaymentController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            return DonateCell.cellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            let cell = tableView.dequeueReusableCellWithIdentifier(String(DonateCell.self), forIndexPath: indexPath) as! DonateCell
            cell.projectIconImageView.setImageFromURL(paymentSystem.item.imageURL)
            cell.projectNameLabel.text = paymentSystem.item.itemName
            return cell
        case NSIndexPath(forRow: 1, inSection: 0):
            let cell = tableView.dequeueReusableCellWithIdentifier(String(TotalCell.self), forIndexPath: indexPath) as! TotalCell
            cell.priceLabel.text = paymentSystem.item.totalAmountFofmattedString
            return cell
        default:
            return UITableViewCell()
        }
    }
}
