//
//  MembershipMemberCardViewController.swift
//  PositionIn
//
//  Created by ng on 2/2/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import CleanroomLogger
import BrightFutures

class MembershipMemberCardViewController : UIViewController {
    
    private let router : MembershipRouter
    
    private var profile : UserProfile?
    private var plan : MembershipPlan?
    
    @IBOutlet var titleNavigationItem: UINavigationItem!
    @IBOutlet weak var membershipCardView: MembershipCardView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
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
        
        self.getData()
    }
    
    func setupInterface() {
        self.title = self.titleNavigationItem.title
        self.navigationItem.rightBarButtonItem = self.titleNavigationItem.rightBarButtonItem
    }
    
    func getData() {
        api().updateCurrentProfileStatus().flatMap { [weak self] (profile : UserProfile) -> Future<MembershipPlan, NSError> in
            self?.profile = profile
            return api().getMembership(self?.profile?.membershipDetails?.membershipPlanId ?? CRUDObjectInvalidId)
            }.flatMap { [weak self] (plan : MembershipPlan) -> Future<CollectionResponse<MembershipPlan>, NSError> in
                self?.plan = plan
                return api().getMemberships()
            }.onSuccess { [weak self] collectionResponse in
                if let strongSelf = self {
                    if collectionResponse.items.isEmpty {
                        strongSelf.upgradeButton.enabled = false
                    }
                    strongSelf.membershipCardView.configure(with: strongSelf.profile!, plan: strongSelf.plan!)
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        strongSelf.membershipCardView.alpha = 1.0
                    })
                }}.onComplete { [weak self] _ in
                    self?.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: Targe-Action
    
    @IBAction func detailsTapped(sender: AnyObject) {
        if let plan = self.plan {
            self.router.showMembershipPlanDetailsViewController(from: self, with: plan, paymentInfo: false)
        }
    }
    
    @IBAction func upgradeTapped(sender: AnyObject) {
        if let plan = self.plan {
            self.router.showPlansViewController(from: self, with: plan)
        }
    }
    
    
    @IBAction func closeTapped(sender: AnyObject) {
        self.router.dismissMembership(from: self)
    }
    
}