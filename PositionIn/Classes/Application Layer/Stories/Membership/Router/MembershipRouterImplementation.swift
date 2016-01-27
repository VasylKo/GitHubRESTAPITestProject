//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipRouterImplementation: BaseRouterImplementation, MembershipRouter {

    func showMembershipPlanDetailsViewController(sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(MembershipPlanDetailsViewController(), animated: true)
    }
    
}
