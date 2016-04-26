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
            strongSelf.router.showMembershipMemberCardViewController(from: strongSelf)
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
