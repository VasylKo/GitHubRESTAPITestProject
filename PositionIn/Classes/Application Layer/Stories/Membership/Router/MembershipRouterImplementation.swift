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
        if (api().isUserHasActiveMembershipPlan()) {
            self.showMembershipMemberCardViewController(from: sourceViewController)
        } else {
            let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate)
            let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual)
            let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
                containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
            sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        let membershipDetailsViewController = MembershipPlanDetailsViewController(router: self, plan: plan)
        sourceViewController.navigationController?.pushViewController(membershipDetailsViewController, animated: true)
    }
    
    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        sourceViewController.navigationController?.pushViewController(MembershipConfirmDetailsViewController(router: self, plan: plan),
            animated: true)
    }
    
    func showMembershipMemberCardViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipMemberCardViewController(router: self), animated: true)
    }
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        sourceViewController.navigationController?.pushViewController(MembershipPaymentViewController(router: self, plan: plan),
            animated: true)
    }
    
    func dismissMembership(from sourceViewController : UIViewController) {
        appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
