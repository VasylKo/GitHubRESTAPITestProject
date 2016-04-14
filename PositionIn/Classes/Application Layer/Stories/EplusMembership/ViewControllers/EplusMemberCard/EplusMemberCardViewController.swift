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
    
    @IBOutlet var titleNavigationItem: UINavigationItem?
    @IBOutlet weak var membershipCardView: EplusMemberCardView?
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
        
        self.setupInterface()
        
        //self.getData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.membershipCard)
    }
    
    func setupInterface() {
        self.title = NSLocalizedString("Your Membership", comment: "EplusMemberCardViewController title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector("closeTapped:"))
    }
    
    /*
    func getData() {
        api().updateCurrentProfileStatus().flatMap { [weak self] (profile : UserProfile) -> Future<MembershipPlan, NSError> in
            self?.profile = profile
            return api().getMembership(self?.profile?.membershipDetails?.membershipPlanId ?? CRUDObjectInvalidId)
            }.flatMap { [weak self] (plan : MembershipPlan) -> Future<CollectionResponse<MembershipPlan>, NSError> in
                self?.plan = plan
                return api().getMemberships()
            }.onSuccess { [weak self] collectionResponse in
                if let strongSelf = self {
                    strongSelf.membershipCardView.configure(with: strongSelf.profile!, plan: strongSelf.plan!)
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        strongSelf.membershipCardView.alpha = 1.0
                        if collectionResponse.items.count > 0 && strongSelf.profile?.membershipDetails?.status == .Active {
                            strongSelf.upgradeView.alpha = 1.0
                        }
                    })
                    strongSelf.configureExpiredView(with: self?.profile?.membershipDetails)
                }}.onComplete { [weak self] _ in
                    //self?.activityIndicator.stopAnimating()
        }
    }
*/
    
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