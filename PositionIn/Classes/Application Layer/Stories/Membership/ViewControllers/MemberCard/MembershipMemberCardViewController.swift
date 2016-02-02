//
//  MembershipMemberCardViewController.swift
//  PositionIn
//
//  Created by ng on 2/2/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import CleanroomLogger

class MembershipMemberCardViewController : UIViewController {
    
    private let router : MembershipRouter
    private let plan : MembershipPlan
    @IBOutlet weak var membershipCardView: MembershipCardView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Initializers
    
    init(router: MembershipRouter, plan : MembershipPlan) {
        self.router = router
        self.plan = plan
        super.init(nibName: String(MembershipMemberCardViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        
        api().getMyProfile().onSuccess { [weak self] profile in
            if let strongSelf = self {
                strongSelf.membershipCardView.configure(with: profile, plan: strongSelf.plan)
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    strongSelf.membershipCardView.alpha = 1.0
                })
            }
        }.onComplete { [weak self] _ in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func setupInterface() {
        self.title = String("Your Membership")
    }
    
    //MARK: Targe-Action
    
    @IBAction func detailsTapped(sender: AnyObject) {
        
    }
    
    @IBAction func upgradeTapped(sender: AnyObject) {
        
    }
    
    @IBAction func shareTapped(sender: AnyObject) {
        
    }
    
}