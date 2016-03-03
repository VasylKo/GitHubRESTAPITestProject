//
//  MembershipMPesaDetailsViewController.swift
//  PositionIn
//
//  Created by ng on 2/8/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm

class MembershipMPesaDetailsViewController: XLFormViewController {
    
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : MembershipRouter
    private let plan : MembershipPlan
    private var headerView : MPesaIndicatorView!
    private var transactionId = ""
    private var creditCardPaymentSuccess: Bool?
    
    //MARK: Initializers
    
    init(router: MembershipRouter, plan: MembershipPlan, creditCardPaymentSuccess: Bool?) {
        self.router = router
        self.plan = plan
        self.creditCardPaymentSuccess = creditCardPaymentSuccess
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
        
        if let creditCardPaymentSuccess = creditCardPaymentSuccess {
            if creditCardPaymentSuccess == true {
                self.headerView.showSuccess()
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self.router.showMembershipMemberCardViewController(from: self)
                }
            }
            else {
                self.headerView.showFailure()
            }
        }
        else {
            let price = String(self.plan.price ?? 0)
            api().membershipCheckoutMpesa(price, nonce: "",
                membershipId: self.plan.objectId).onSuccess { [weak self] transactionId in
                    self?.transactionId = transactionId
                    self?.pollStatus()
                }.onFailure(callback: { [weak self] _ in
                    self?.headerView.showFailure()
                    })
        }
    }

    @objc func pollStatus() {
        api().transactionStatusMpesa(transactionId).onSuccess { [weak self] status in
            self?.headerView.showSuccess()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                if let strongSelf = self {
                    strongSelf.router.showMembershipMemberCardViewController(from: strongSelf)
                }
            }
        }.onFailure { [weak self] error in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                self?.pollStatus()
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
        let form = XLFormDescriptor(title: NSLocalizedString("Payment", comment: "Donate"))
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypePayment)
        
        donateProjectRow.cellConfigAtConfigure["planString"] = plan.name
        donateProjectRow.cellConfigAtConfigure["planImage"] = UIImage(named : plan.membershipImageName)
        
        if let price = plan.price {
            donateProjectRow.cellConfigAtConfigure["priceString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
            donateProjectRow.cellConfigAtConfigure["totalString"] = AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(integer:
                price)) ?? ""
        }
        
        donateToSection.addFormRow(donateProjectRow)
        
        self.form = form
    }
    
}