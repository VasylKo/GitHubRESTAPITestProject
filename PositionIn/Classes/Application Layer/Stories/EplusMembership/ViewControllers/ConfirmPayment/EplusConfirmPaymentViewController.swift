//
//  EplusConfirmPaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm

class EplusConfirmPaymentViewController: XLFormViewController {
    
    private let pageView = MembershipPageView(pageCount: 3)
    let router : EplusMembershipRouter
    private let plan : EplusMembershipPlan
    var headerView : MPesaIndicatorView!
    private var transactionId = ""
    private let card: CardItem
    private let isPaymentSuccessful: Bool
    
    
    //MARK: Initializers
    
    init(router: EplusMembershipRouter, plan: EplusMembershipPlan, card: CardItem, isSuccess: Bool = false) {
        self.router = router
        self.plan = plan
        self.card = card
        isPaymentSuccessful = isSuccess
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        self.initializeForm()
        
        switch card {
        case .MPesa:
           checkMPESAPurchase()
            
        case .CreditDebitCard:
            if isPaymentSuccessful {
                paymentDidSuccess()
            } else {
                paymentDidFail()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.pageView.sizeToFit()
        var frame: CGRect = self.pageView.frame
        frame.origin.x = 0
        frame.origin.y = self.view.frame.size.height - frame.size.height
        self.pageView.frame = frame
        
        self.view.tintColor = UIScheme.mainThemeColor
    }
    
    func setupInterface() {
        
        view.tintColor = UIScheme.mainThemeColor
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(1)
        self.view.addSubview(pageView)
        
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(MPesaIndicatorView.self), owner: nil, options: nil).first as? MPesaIndicatorView {
            self.headerView = headerView
            self.tableView.tableHeaderView = headerView
        }
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Payment", comment: "Comnird ambulance payment screen name"))
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeAmbulancePayment)
        
        donateProjectRow.cellConfigAtConfigure["planString"] = plan.name
        donateProjectRow.cellConfigAtConfigure["planImage"] = UIImage(named : plan.membershipImageName)
        
        if let price = plan.price {
            donateProjectRow.cellConfigAtConfigure["totalString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
        }
        
        donateToSection.addFormRow(donateProjectRow)
        
        self.form = form
    }
    
    //MARK: - MPESA payment
    func checkMPESAPurchase() {
        let price = String(self.plan.price ?? 0)
        api().membershipCheckoutMpesa(price, nonce: "",
            membershipId: self.plan.objectId).onSuccess { [weak self] transactionId in
                self?.transactionId = transactionId
                self?.pollMPESAStatus()
                //self?.sendPaymentEventToAnalytics(success: true)
            }.onFailure(callback: { [weak self] _ in
                self?.paymentDidFail()
                })
    }
    
    
    @objc func pollMPESAStatus() {
        api().transactionStatusMpesa(transactionId).onSuccess { [weak self] status in
            self?.paymentDidSuccess()
            }.onFailure { [weak self] error in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self?.pollMPESAStatus()
                }
        }
    }
    
    
    //MARK: - End of payment
    private func paymentDidSuccess() {
        headerView.showSuccess()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            //TODO: add route to plan card
            //self.router.showMembershipMemberCardViewController(from: self)
        }
    }
    
    
    private func paymentDidFail() {
        headerView.showFailure()
        //sendPaymentEventToAnalytics(success: false)
    }
    
    //TODO: add Analytic events
    //MARK: - Analytic
    /*
    func sendPaymentEventToAnalytics(success success: Bool) {
        let planPrice = NSNumber(integer: plan.price ?? 0)
        let paymentLabel = success ? NSLocalizedString("Payment Completed", comment: "MPesaIndicatorView") : NSLocalizedString("Payment Failed", comment: "MPesaIndicatorView")
        trackEventToAnalytics(AnalyticCategories.membership, action: AnalyticActios.paymentOutcome, label: paymentLabel, value: planPrice)
        
    }
*/
 
}
