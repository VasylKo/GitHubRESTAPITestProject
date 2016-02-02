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
    @IBOutlet weak var membershipCardView: MembershipCardView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Initializers
    
    init(router: MembershipRouter) {
        self.router = router
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
            self?.membershipCardView.configure(with: profile, membershipPlan: nil, memebershipDetails: nil)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self?.membershipCardView.alpha = 1.0
            })
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