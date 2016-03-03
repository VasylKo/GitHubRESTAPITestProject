//
//  MembershipRouter.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol MembershipRouter : BaseRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController)
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan, onlyPlanInfo : Bool)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String)

    func showMembershipMemberCardViewController(from sourceViewController : UIViewController)

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showPlansViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController)
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan, creditCardPaymentSuccess: Bool?)
    
    func dismissMembership(from sourceViewController : UIViewController)
}