//
//  MembershipPaymentTransactionViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 26/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipPaymentTransactionViewController: CommonPaymentViewController {

    // MARK: - Rivate ivars
    private let router : MembershipRouter
    private let pageView = MembershipPageView(pageCount: 3)
    private var sectionsCount = 1
    
    // MARK: - Init, PaymentController
    init (router: MembershipRouter, paymentSystem: PaymentSystem) {
        self.router = router
        super.init(paymentSystem: paymentSystem)
  
    }

    required init(paymentSystem: PaymentSystem) {
        fatalError("init(paymentSystem:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerNib(UINib(nibName: String(PaymentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(PaymentTableViewCell.self))
    }
    
    
    private func setupInterface() {
        
        view.tintColor = UIScheme.mainThemeColor
        
        pageView.sizeToFit()
        pageView.redrawView(1)
        view.addSubview(pageView)
        
        //add pageView to bottom with constaints
        pageView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: pageView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: pageView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: pageView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: pageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: MembershipPageView.pageViewHeight)
        
        pageView.addConstraint(heightConstraint)
        view.addConstraints([bottomConstraint, trailingConstraint, leadingConstraint])
  
    }
    
    override func paymentDidSuccess() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.router.showMembershipMemberCardViewController(from: strongSelf, showBackButton: false)
        }
        
        sendPaymentEventToAnalytics(label: NSLocalizedString("Payment Completed"))
    }
    
    override func paymentDidFail(error: NSError) {
        super.paymentDidFail(error)
        sendPaymentEventToAnalytics(label: error.localizedDescription)
    }
    
    //MARK: - Analytic tracking
    private func sendPaymentEventToAnalytics(label label: String) {
        let paymentAmountNumber = NSNumber(float: paymentSystem.item.totalAmount)
        trackEventToAnalytics(AnalyticCategories.membership, action: AnalyticActios.paymentOutcome, label: label, value: paymentAmountNumber)
    }

}

//MARK: - UITableViewDataSource
extension MembershipPaymentTransactionViewController: UITableViewDataSource {
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
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PaymentTableViewCell.self), forIndexPath: indexPath) as! PaymentTableViewCell
            cell.totalLabel.text = paymentSystem.item.totalAmountFofmattedString
            cell.planName.text = paymentSystem.item.itemName
            cell.planImageView.image = paymentSystem.item.image
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension MembershipPaymentTransactionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            return PaymentTableViewCell.cellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
}
