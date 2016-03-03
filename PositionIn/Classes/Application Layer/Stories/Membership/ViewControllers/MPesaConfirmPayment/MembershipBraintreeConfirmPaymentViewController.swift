//
//  MembershipBraintreeConfirmPaymentViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipBraintreeConfirmPaymentViewController: MembershipMPesaConfirmPaymentViewController {
    
    private var creditCardPaymentSuccess: Bool?

    //MARK: Initializers
    
    init(router: MembershipRouter, plan: MembershipPlan, creditCardPaymentSuccess: Bool?) {
        self.creditCardPaymentSuccess = creditCardPaymentSuccess
        super.init(router: router, plan: plan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        self.initializeForm()
        
        if let creditCardPaymentSuccess = self.creditCardPaymentSuccess {
            if creditCardPaymentSuccess == true {
                self.headerView.showSuccess()
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    super.router.showMemberDetailsViewController(from: self)
                }
            }
            else {
                self.headerView.showFailure()
            }
        }
    }
    
}
