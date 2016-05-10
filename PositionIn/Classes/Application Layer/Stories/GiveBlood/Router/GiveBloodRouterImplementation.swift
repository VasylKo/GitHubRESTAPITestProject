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
                self.showGiveBloodTypeViewController(from: sourceViewController)
            }
        }
    }

    func showIntroViewController(from sourceViewController : UIViewController) {
        sourceViewController.navigationController?.pushViewController(IntroPageViewController(router:  self), animated: true)
    }
    
    func showGiveBloodCentersViewController(from sourceViewController : UIViewController) {
        let controller = Storyboards.Main.instantiateExploreViewControllerId()
        controller.homeItem = .GiveBlood
        sourceViewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showGiveBloodTypeViewController(from sourceViewController : UIViewController) {
        let controller = BloodTypeViewController(router: self)
        sourceViewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showQuestionBloodDonorController(from sourceViewController : UIViewController, type: QuestionBloodDonorViewControllerType) {
        let controller =  QuestionBloodDonorViewController(router: self, type: type)
        sourceViewController.navigationController?.pushViewController(controller, animated: true)
    }
}
