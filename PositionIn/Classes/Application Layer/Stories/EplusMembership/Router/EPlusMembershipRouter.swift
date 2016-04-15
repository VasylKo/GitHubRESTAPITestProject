//
//  EplusMembershipRouter.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol EPlusMembershipRouter : BaseRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool?)
    
    func showPlansViewController(from sourceViewController : UIViewController /*, with plan : EplusMembershipPlan */)
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan /*, onlyPlanInfo : Bool*/)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String)

    func showMembershipMemberCardViewController(from sourceViewController : UIViewController)

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan)
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan)
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController)
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan)
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan, creditCardPaymentSuccess: Bool?)
    
    func showCallAmbulanceViewController(from sourceViewController : UIViewController)
    
    func dismissMembership(from sourceViewController : UIViewController)
}