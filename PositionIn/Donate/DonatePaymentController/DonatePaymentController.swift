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
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerNib(UINib(nibName: String(DonateCell.self), bundle: nil), forCellReuseIdentifier: String(DonateCell.self))
        tableView?.registerNib(UINib(nibName: String(TotalCell.self), bundle: nil), forCellReuseIdentifier: String(TotalCell.self))
        tableView?.registerNib(UINib(nibName: String(SuccessDonationInfoCell.self), bundle: nil), forCellReuseIdentifier: String(SuccessDonationInfoCell.self))
    }
    
    //MARK: - Override base class behaviour
    override func paymentDidSuccess() {
        super.paymentDidSuccess()
        sendDonationEventToAnalytics(label: NSLocalizedString("Payment Completed"))
        
        //Add success donation section
        sectionsCount = 2
        tableView?.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
        trackScreenToAnalytics(AnalyticsLabels.donateConfirmation)
    }
    
    override func paymentDidFail(error: NSError) {
        super.paymentDidFail(error)
        sendDonationEventToAnalytics(label: error.localizedDescription)
    }
    
    override func closeButtonTappedAfterSuccessPayment(sender: AnyObject) {
        if let viewController = viewControllerToOpenOnComplete {
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            sideBarController?.executeAction(SidebarViewController.defaultAction)
        }
    }

    //MARK: - Analytic tracking
    private func sendDonationEventToAnalytics(label label: String) {
        let donationTypeName = AnalyticCategories.labelForDonationType(donationType)
        let paymentAmountNumber = NSNumber(float: paymentSystem.item.totalAmount)
        trackEventToAnalytics(donationTypeName, action: AnalyticActios.paymentOutcome, label: label, value: paymentAmountNumber)
    }
    
}

//MARK: - UITableViewDataSource
extension DonatePaymentController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        case NSIndexPath(forRow: 0, inSection: 1):
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SuccessDonationInfoCell.self), forIndexPath: indexPath) as! SuccessDonationInfoCell
            cell.amountString =  paymentSystem.item.totalAmountFofmattedString
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension DonatePaymentController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            return DonateCell.cellHeight
        case NSIndexPath(forRow: 0, inSection: 1):
            return SuccessDonationInfoCell.cellHeight
            
        default:
            return UITableViewAutomaticDimension
        }
    }
}
