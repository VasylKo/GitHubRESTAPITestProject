//
//  MembershipRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class GiveBloodRouterImplementation: BaseRouterImplementation, GiveBloodRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController) {
        
        showIntroViewController(from: sourceViewController)
        //showGiveBloodCentersViewController(from: sourceViewController)
    }
    
    func showIntroViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(IntroPageViewController(router: self), animated: true)
    }
    
    func showGiveBloodCentersViewController(from sourceViewController : UIViewController) {
        let controller = Storyboards.Main.instantiateExploreViewControllerId()
        controller.homeItem = .GiveBlood
        sourceViewController.navigationController?.pushViewController(controller, animated: true)
    }
    
}
