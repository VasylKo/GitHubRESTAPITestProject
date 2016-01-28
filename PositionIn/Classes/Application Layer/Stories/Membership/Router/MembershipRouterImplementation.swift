//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipRouterImplementation: BaseRouterImplementation, MembershipRouter {
    
    func showInitialViewController(sourceViewController : UIViewController) {
        let corporatePlansViewController = MembershipCorporatePlansViewController(router: self)
        let individualPlansViewController = MembershipIndividualPlansViewController(router: self)
        let initialViewController = SegmentedControlContainerViewController(mapping: ["Individual" : individualPlansViewController,
                                                                                      "Corporate"  : corporatePlansViewController],
                                                                            title: "Membership")
        
        sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
    }
    
    func showMembershipPlanDetailsViewController(sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipPlanDetailsViewController(router: self), animated: true)
    }
    
}
