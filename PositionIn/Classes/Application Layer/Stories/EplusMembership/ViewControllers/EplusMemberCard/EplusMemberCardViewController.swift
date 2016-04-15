//
//  EplusMemberCard.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import CleanroomLogger
import BrightFutures

class EplusMemberCardViewController : UIViewController {
    
    private let router : EplusMembershipRouter
    private var profile : UserProfile?
    private var plan : EplusMembershipPlan?
    
    @IBOutlet weak var eplusMemberCardView: EplusMemberCardView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var detailsButton: UIButton?
    
    @IBOutlet weak var infoLabel: UILabel?

    //MARK: Initializers
    
    init(router: EplusMembershipRouter) {
        self.router = router
        super.init(nibName: String(EplusMemberCardViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInterface()
        detailsButton?.enabled = false
        getData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.membershipCard)
    }
    
    func setupInterface() {
        title = NSLocalizedString("Your Membership", comment: "EplusMemberCardViewController title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector("closeTapped:"))
    }
    
    
    func getData() {
        
        api().getMyProfile().flatMap { [weak self] (profile : UserProfile) -> Future<EplusMembershipPlan, NSError> in
            self?.profile = profile
            return api().getAmbulanceMembership(profile.eplusMembershipDetails?.membershipPlanId ?? CRUDObjectInvalidId)
            
            }.onSuccess { [weak self] (plan: EplusMembershipPlan) -> Void in
                guard let strongSelf = self, profile = strongSelf.profile else { return }
                strongSelf.plan = plan
                strongSelf.eplusMemberCardView?.configureWith(profile: profile, plan: plan)
                strongSelf.detailsButton?.enabled = true
                
                //Show eplus memver card
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    strongSelf.eplusMemberCardView?.alpha = 1.0
                })
                
            }.onComplete { [weak self] _ in
                self?.activityIndicator?.stopAnimating()
        }
    }

    
    //MARK: Targe-Action
    
    @IBAction func detailsTapped(sender: AnyObject) {
        //TODO: Implement PlanRoueter
        if let plan = self.plan {
            router.showMembershipPlanDetailsViewController(from: self, with: plan, onlyPlanInfo: true)
        }
    }
    
    
    func closeTapped(sender: AnyObject) {
        self.router.dismissMembership(from: self)
    }
    


}