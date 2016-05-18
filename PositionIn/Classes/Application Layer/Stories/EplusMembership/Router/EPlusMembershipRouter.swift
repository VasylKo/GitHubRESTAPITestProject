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
    
    func showPlansViewController(from sourceViewController : UIViewController, onlyPlansInfo : Bool)
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan, onlyPlanInfo : Bool)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController, phoneNumber : String, validationCode : String)

    func showMembershipMemberCardViewController(from sourceViewController : UIViewController, hidesBackButton: Bool, canTransitToInfo: Bool)

    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan)
    
    func showPaymentViewController(from sourceViewController : UIViewController, with plan : EPlusMembershipPlan)
    
    func showMemberDetailsViewController(from sourceViewController : UIViewController)
    
    func showMembershipPaymentTransactionViewController(from sourceViewController : UIViewController, withPaymentSystem : PaymentSystem, plan: EPlusMembershipPlan)
    
    func showCallAmbulanceViewController(from sourceViewController : UIViewController)
    
    func showAboutController(from sourceViewController : UIViewController)
    
    func showServiceDetailsController(from sourceViewController : UIViewController, with service: EPlusService)
    
    func showContactSupportController(from sourceViewController : UIViewController)
    
    func dismissMembership(from sourceViewController : UIViewController)
}