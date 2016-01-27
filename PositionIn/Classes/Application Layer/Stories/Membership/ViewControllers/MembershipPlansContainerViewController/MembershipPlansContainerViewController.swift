//
//  MembershipPlansContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipPlansContainerViewController : UIViewController {
    
    private let router : MembershipRouter
    
    init(router: MembershipRouter = MembershipRouterImplementation()) {
        self.router = router
        super.init(nibName: String(MembershipPlansContainerViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
