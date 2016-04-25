//
//  EplusMembershipRouterImplementation.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusMembershipRouterImplementation: BaseRouterImplementation, EPlusMembershipRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool? = nil) {
        api().getEPlusActiveMembership().onSuccess { [unowned self] (membershipDetails: EplusMembershipDetails?) -> Void in
            if membershipDetails?.objectId != CRUDObjectInvalidId {
                self.showCallAmbulanceViewController(from: sourceViewController)
            } else {
                self.showPlansViewController(from: sourceViewController, onlyPlansInfo: false)
            }
        }
    }
    
    func showPlansViewController(from sourceViewController : UIViewController, onlyPlansInfo : Bool) {
        let plansViewController = EPlusPlansViewController(router: self, onlyPlansInfo: onlyPlansInfo)
        sourceViewController.navigationController?.pushViewController(plansViewController, animated: true)
    }
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan, onlyPlanInfo : Bool) {
        let membershipDetailsViewController = EPlusAmbulanceDetailsController(router: self, plan: plan, onlyPlanInfo: onlyPlanInfo)
            sourceViewController.navigationController?.pushViewController(membershipDetailsViewController, animated: true)
    }

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan) {
        sourceViewController.navigationController?.pushViewController(EPlusMembershipConfirmDetailsViewController(router: self, plan: plan),
            animated: true)
    }
    
    func showMembershipMemberCardViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(EPlusMemberCardViewController(router: self), animated: true)
    }
    
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String) {
        //sourceViewController.navigationController?.pushViewController(MembershipMemberProfileViewController(router: self, phoneNumber: phoneNumber, validationCode: validationCode), animated: true)
    }
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan) {
        let paymentController = EPlusPaymentViewController(router: self, plan: plan)
        sourceViewController.navigationController?.pushViewController(paymentController, animated: true)
    }
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController) {
//        sourceViewController.navigationController?.pushViewController(MembershipMemberDetailsViewController(router: self),
//            animated: true)
    }
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan) {
//        let mpesaConfirmPaymentViewController = MembershipMPesaConfirmPaymentViewController(router: self, plan: plan)
//        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan, creditCardPaymentSuccess: Bool?) {
//        let mpesaConfirmPaymentViewController = MembershipBraintreeConfirmPaymentViewController(router: self, plan: plan, creditCardPaymentSuccess: creditCardPaymentSuccess)
//        sourceViewController.navigationController?.pushViewController(mpesaConfirmPaymentViewController, animated: true)
    }
    
    func showCallAmbulanceViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(Storyboards.Onboarding.instantiateCallAmbulanceViewController(), animated: true)
    }
    
    func showAboutController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(AboutEplusServiceController(router: self), animated: true)
    }
    
    func showServiceDetailsController(from sourceViewController : UIViewController, with service: EPlusService) {
        sourceViewController.navigationController?.pushViewController(EPlusServiceDetailsViewController(router: self, service: service), animated: true)
    }
    
    func showContactSupportController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(EPlusContactsSupportController(router: self), animated: true)
    }
    
    func dismissMembership(from sourceViewController : UIViewController) {
        appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
