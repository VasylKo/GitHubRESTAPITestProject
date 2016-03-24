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
    
    @IBOutlet weak var expiredDescriptionLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var expiredButton: UIButton!
    @IBOutlet weak var expiredButtonAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var expiredHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var upgradeView: UIView!
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
        
        self.expiredHeightConstraint.constant = 0
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
                    strongSelf.membershipCardView.configure(with: strongSelf.profile!, plan: strongSelf.plan!)
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        strongSelf.membershipCardView.alpha = 1.0
                        if collectionResponse.items.count > 0 && strongSelf.profile?.membershipDetails?.status == .Active {
                            strongSelf.upgradeView.alpha = 1.0
                        }
                    })
                    strongSelf.configureExpiredView(with: self?.profile?.membershipDetails)
                }}.onComplete { [weak self] _ in
                    self?.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: Targe-Action
    
    @IBAction func detailsTapped(sender: AnyObject) {
        if let plan = self.plan {
            self.router.showMembershipPlanDetailsViewController(from: self, with: plan, onlyPlanInfo: true)
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
    
    @IBAction func renewTapped(sender: AnyObject) {
        self.router.showInitialViewController(from: self, hasActivePlan: false)
    }

    //MARK: Private
    
    func configureExpiredView(with details: MembershipDetails?) {
        if let membershipDetails = details {
            switch membershipDetails.status {
            case .Active, .Unknown:
                self.expiredHeightConstraint.constant = 0
                break
            case .isAboutToExpired:
                self.expiredHeightConstraint.constant = 96
                self.expiredDescriptionLabel.text = NSLocalizedString("Your membership is about to expired")
                self.daysLeftLabel.hidden = false
                self.daysLeftLabel.text = NSLocalizedString("\(membershipDetails.daysLeft ?? 0) Days Left")
                self.expiredButtonAlignmentConstraint.constant = 65
                break
            case .Expired:
                self.expiredHeightConstraint.constant = 96
                self.expiredDescriptionLabel.text = NSLocalizedString("Your membership is expired")
                self.daysLeftLabel.hidden = true
                self.expiredButtonAlignmentConstraint.constant = 0
                break
            }
        } else {
            self.expiredHeightConstraint.constant = 0
        }
    }
}