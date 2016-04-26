//
//  MembershipRouter.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol MembershipRouter : BaseRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool?)
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan, onlyPlanInfo : Bool)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String)

    func showMembershipMemberCardViewController(from sourceViewController : UIViewController, showBackButton: Bool)

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showPlansViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController)
    
    func showMembershipPaymentTransactionViewController(from sourceViewController : UIViewController, withPaymentSystem : PaymentSystem)
    
    func dismissMembership(from sourceViewController : UIViewController)
}