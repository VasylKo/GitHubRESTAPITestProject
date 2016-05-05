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
        api().getDonorInfo().onSuccess { donorInfo in
            guard let status = donorInfo.donorStatus else {
                self.showIntroViewController(from: sourceViewController)
                return
            }
            
            switch status {
            case .Undefined:
                self.showIntroViewController(from: sourceViewController)
            default:
                self.showGiveBloodCentersViewController(from: sourceViewController)
            }
        }
        
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
