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
    
    func showMembershipPlanDetailsViewController(from sourceViewController : UIViewController, with plan : MembershipPlan)
    
    func showMembershipConfirmDetailsViewController(from sourceViewController : UIViewController)
    
    func showMembershipMemberProfile(from sourceViewController : UIViewController)

}