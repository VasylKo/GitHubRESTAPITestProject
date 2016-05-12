//
//  MembershipRouter.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol GiveBloodRouter : BaseRouter {
    
    func showInitialViewController(from sourceViewController : UIViewController)
    
    func showIntroViewController(from sourceViewController : UIViewController)
    
    func showGiveBloodCentersViewController(from sourceViewController : UIViewController)
    
    func showGiveBloodTypeViewController(from sourceViewController : UIViewController)
    
    func showQuestionBloodDonorController(from sourceViewController : UIViewController, type: QuestionBloodDonorViewControllerType)
    
    func showThankYouViewController(from sourceViewController : UIViewController)
    
}