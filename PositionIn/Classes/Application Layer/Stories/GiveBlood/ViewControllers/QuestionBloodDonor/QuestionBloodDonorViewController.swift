//
//  QuestionBloodDonorViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 06/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

enum QuestionBloodDonorViewControllerType {
    case Unknown, AlreadyDonor, WouldBeDonor
}

class QuestionBloodDonorViewController: UIViewController, GiveBloodAlertViewDelegate {
    
    init(router: GiveBloodRouter, type: QuestionBloodDonorViewControllerType) {
        self.router = router
        self.type = type
        super.init(nibName: NSStringFromClass(QuestionBloodDonorViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        alertView.layer.shadowColor = UIColor.blackColor().CGColor
        alertView.layer.shadowOffset = CGSizeMake(0, 2);
        alertView.layer.shadowOpacity = 0.1
        alertView.layer.shadowRadius = 1.0;
        alertView.layer.masksToBounds = false
        alertView.layer.shadowOpacity = 0.1
        alertView.layer.cornerRadius = 3
        
        switch type {
        case .AlreadyDonor:
            self.alertView.title = NSLocalizedString("Are you a blood donor?")
        case .WouldBeDonor:
            self.alertView.title = NSLocalizedString("Would you like to be a blood donor?")
        default:
            break;
        }
    }
    
    func yesTapped() {
        self.router.showGiveBloodTypeViewController(from: self)
    }
    
    func noTapped() {
        switch type {
        case .AlreadyDonor :
            self.router.showQuestionBloodDonorController(from: self, type: .WouldBeDonor)
            break
        case .WouldBeDonor:
            self.router.showUnableToDonateViewController(from: self)
        default: break
        }
    }
    
    private let router : GiveBloodRouter
    private var type: QuestionBloodDonorViewControllerType = .Unknown
    
    @IBOutlet weak var alertView: GiveBloodAlertView!
}
