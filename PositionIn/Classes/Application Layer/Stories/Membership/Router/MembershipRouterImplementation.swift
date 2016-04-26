//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipRouterImplementation: BaseRouterImplementation, MembershipRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool? = nil) {
        switch hasActivePlan {
        case .Some(let active):
            if (active) {
                self.showMembershipMemberCardViewController(from: sourceViewController, showBackButton: true)
            } else {
                let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate, currentMembershipPlan: nil)
                let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual, currentMembershipPlan: nil)
                let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
                    containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
                sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
            }
        case .None:
            if (api().isUserHasActiveMembershipPlan()) {
                self.showMembershipMemberCardViewController(from: sourceViewController, showBackButton: true)
            } else {
                let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate, currentMembershipPlan: nil)
                let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual, currentMembershipPlan: nil)
                let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
                    containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
                sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
            }
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
    
    func showMembershipMemberCardViewController(from sourceViewController : UIViewController, showBackButton: Bool) {
        sourceViewController.navigationController?.pushViewController(MembershipMemberCardViewController(router: self, showBackButton: showBackButton), animated: true)
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
    
    func showMembershipPaymentTransactionViewController(from sourceViewController : UIViewController, withPaymentSystem paymentSystem: PaymentSystem) {
        let paymentTransactionController = MembershipPaymentTransactionViewController(router: self, paymentSystem: paymentSystem)
        sourceViewController.navigationController?.pushViewController(paymentTransactionController, animated: true)
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
