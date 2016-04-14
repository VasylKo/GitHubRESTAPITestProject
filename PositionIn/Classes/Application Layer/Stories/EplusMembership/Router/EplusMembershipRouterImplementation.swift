//
//  EplusMembershipRouterImplementation.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EplusMembershipRouterImplementation: BaseRouterImplementation, EplusMembershipRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool? = nil) {
        
        var family = EplusMembershipPlan()
        family.objectId = CRUDObjectId(EplusMembershipPlan.PlanType.Family.rawValue)
        family.name = "Family"
        family.price = 6000
        family.costDescription = "KSH 6,000 Annually"
        family.planDescription = "This Cover provides a 24/7 Ambulance membership for a family in towns where E-plus has ambulances.\n\nMaximum number of 6 family members (principle, spouse and 4 children)"
        var familyBenefits = [String]()
        familyBenefits.append("Access to Medical Helpline 24/7.")
        familyBenefits.append("Unlimited emergency ambulance services.")
        familyBenefits.append("Treatment and stabilization on site.")
        familyBenefits.append("Transfer to Hospital after stabilization.")
        family.benefits = familyBenefits
        var familyOtherBenefits = [String]()
        familyOtherBenefits.append("No age limit.")
        familyOtherBenefits.append("No pre existing conditions.")
        familyOtherBenefits.append("Congenital conditions covered.")
        familyOtherBenefits.append("Medically indicated transfers from Hospital to home.")
        family.otherBenefits = familyOtherBenefits
        
        showMembershipConfirmDetailsViewController(from: sourceViewController, with: family)
        
        
//        switch hasActivePlan {
//        case .Some(let active):
//            if (active) {
//                self.showMembershipMemberCardViewController(from: sourceViewController)
//            } else {
//                let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate, currentMembershipPlan: nil)
//                let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual, currentMembershipPlan: nil)
//                let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
//                    containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
//                sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
//            }
//        case .None:
//            if (api().isUserHasActiveMembershipPlan()) {
//                self.showMembershipMemberCardViewController(from: sourceViewController)
//            } else {
//                let corporatePlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Corporate, currentMembershipPlan: nil)
//                let individualPlansViewController = MembershipPlansViewController(router: self, type: MembershipPlan.PlanType.Individual, currentMembershipPlan: nil)
//                let initialViewController = SegmentedControlContainerViewController(labels: ["Individual", "Corporate"],
//                    containeredViewControllers: [individualPlansViewController, corporatePlansViewController], title: "Membership")
//                sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
//            }
//        }

    }
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan, onlyPlanInfo : Bool) {
//        let membershipDetailsViewController = MembershipPlanDetailsViewController(router: self, plan: plan, onlyPlanInfo: onlyPlanInfo)
//        sourceViewController.navigationController?.pushViewController(membershipDetailsViewController, animated: true)
    }

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan) {
        sourceViewController.navigationController?.pushViewController(EplusMembershipConfirmDetailsViewController(router: self, plan: plan), animated: true)
    }
    
    func showMembershipMemberCardViewController(from sourceViewController : UIViewController) {
        //sourceViewController.navigationController?.pushViewController(MembershipMemberCardViewController(router: self), animated: true)
    }
    
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String) {
        //sourceViewController.navigationController?.pushViewController(MembershipMemberProfileViewController(router: self, phoneNumber: phoneNumber, validationCode: validationCode), animated: true)
    }
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan) {
//        sourceViewController.navigationController?.pushViewController(MembershipPaymentViewController(router: self, plan: plan),
//            animated: true)
    }
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController) {
//        sourceViewController.navigationController?.pushViewController(MembershipMemberDetailsViewController(router: self),
//            animated: true)
    }
    
    func showPlansViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan) {
//        let plansViewController = MembershipPlansViewController(router: self, type: plan.type, currentMembershipPlan: plan)
//        sourceViewController.navigationController?.pushViewController(plansViewController, animated: true)
    }
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan) {
//        let mpesaConfirmPaymentViewController = MembershipMPesaConfirmPaymentViewController(router: self, plan: plan)
//        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan, creditCardPaymentSuccess: Bool?) {
//        let mpesaConfirmPaymentViewController = MembershipBraintreeConfirmPaymentViewController(router: self, plan: plan, creditCardPaymentSuccess: creditCardPaymentSuccess)
//        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
    
    func showCallAmbulanceViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(Storyboards.Onboarding.instantiateCallAmbulanceViewController(), animated: true)
    }
    
    func dismissMembership(from sourceViewController : UIViewController) {
        //        appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
        //        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
