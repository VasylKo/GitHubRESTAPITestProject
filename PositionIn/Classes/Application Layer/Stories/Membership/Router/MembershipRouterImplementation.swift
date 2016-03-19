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
            let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate, currentMembershipPlan: nil)
            let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual, currentMembershipPlan: nil)
            let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
                containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
            sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan, onlyPlanInfo : Bool) {
        let membershipDetailsViewController = MembershipPlanDetailsViewController(router: self, plan: plan, onlyPlanInfo: onlyPlanInfo)
        sourceViewController.navigationController?.pushViewController(membershipDetailsViewController, animated: true)
    }

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        sourceViewController.navigationController?.pushViewController(MembershipConfirmDetailsViewController(router: self, plan: plan),
            animated: true)
    }
    
    func showMembershipMemberCardViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipMemberCardViewController(router: self), animated: true)
    }
    
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String) {
        sourceViewController.navigationController?.pushViewController(MembershipMemberProfileViewController(router: self, phoneNumber: phoneNumber, validationCode: validationCode), animated: true)
    }
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        sourceViewController.navigationController?.pushViewController(MembershipPaymentViewController(router: self, plan: plan),
            animated: true)
    }
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipMemberDetailsViewController(router: self),
            animated: true)
    }
    
    func showPlansViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        let plansViewController = MembershipPlansViewController(router: self, type: plan.type, currentMembershipPlan: plan)
        sourceViewController.navigationController?.pushViewController(plansViewController, animated: true)
    }
    
    func dismissMembership(from sourceViewController : UIViewController) {
        appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan) {
        let mpesaConfirmPaymentViewController = MembershipMPesaConfirmPaymentViewController(router: self, plan: plan)
        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan, creditCardPaymentSuccess: Bool?) {
        let mpesaConfirmPaymentViewController = MembershipBraintreeConfirmPaymentViewController(router: self, plan: plan, creditCardPaymentSuccess: creditCardPaymentSuccess)
        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
}
