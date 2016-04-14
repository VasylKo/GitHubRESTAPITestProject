//
//  EplusMembershipRouter.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol EplusMembershipRouter : BaseRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController, hasActivePlan: Bool?)
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan, onlyPlanInfo : Bool)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String)

    func showMembershipMemberCardViewController(from sourceViewController : UIViewController)

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan)
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan)
    
    func showPlansViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan)
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController)
    
    func showMPesaConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan)
    
    func showBraintreeConfirmPaymentViewController(from sourceViewController : UIViewController, with plan : EplusMembershipPlan, creditCardPaymentSuccess: Bool?)
    
    func dismissMembership(from sourceViewController : UIViewController)
}