//
//  MembershipPlanPaymentViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipPlanPaymentViewController : UIViewController {
    
    private let router : MembershipRouter
    
    init(router: MembershipRouter) {
        self.router = router
        super.init(nibName: String(MembershipPlanPaymentViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

