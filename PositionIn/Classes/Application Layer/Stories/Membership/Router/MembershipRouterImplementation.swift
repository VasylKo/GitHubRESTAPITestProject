//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipRouterImplementation: BaseRouterImplementation, MembershipRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController) {
        let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate)
        let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual)
        let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
                                            containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
        
        sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
    }
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        let membershipDetailsViewController = MembershipPlanDetailsViewController(router: self, plan: plan)
        sourceViewController.navigationController?.pushViewController(membershipDetailsViewController, animated: true)
    }
    
}
