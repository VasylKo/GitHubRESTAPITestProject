//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipRouterImplementation: BaseRouterImplementation, MembershipRouter {
    
    func showInitialViewController(sourceViewController : UIViewController) {
//        let corporatePlansViewController = CorporatePlansViewController(router: self)
//        let individualPlansViewController = IndividualPlansViewController(router: self)
//        let initialViewController = MembershipPlansContainerViewController(router: self,
//                                                       containeredViewControllers: [corporatePlansViewController, individualPlansViewController])
//        sourceViewController.navigationController?.pushViewController(initialViewController, animated: true)
    }
    
    func showMembershipPlanDetailsViewController(sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipPlanDetailsViewController(router: self), animated: true)
    }
    
    func showMembershipConfirmDetailsViewController(sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipConfirmDetailsViewController(router: self), animated: true)
    }
    
}
