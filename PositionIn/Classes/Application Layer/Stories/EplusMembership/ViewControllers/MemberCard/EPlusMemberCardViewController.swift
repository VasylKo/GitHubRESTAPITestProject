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

class EPlusMemberCardViewController : UIViewController {
    
    private let router : EPlusMembershipRouter
    private var profile : UserProfile?
    private var plan : EPlusMembershipPlan?
    private var planDetails : EplusMembershipDetails?
    private var canTransitToInfo : Bool
    private lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    @IBOutlet weak var eplusMemberCardView: EPlusMemberCardView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var detailsButton: UIButton?
    
    @IBOutlet weak var infoSectionViewContainer: UIView?
    @IBOutlet weak var dateRangeLabel: UILabel?

    //MARK: Initializers
    
    init(router: EPlusMembershipRouter, canTransitToInfo: Bool) {
        self.router = router
        self.canTransitToInfo = canTransitToInfo
        super.init(nibName: NSStringFromClass(EPlusMemberCardViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInterface()
        detailsButton?.enabled = false
        eplusMemberCardView?.alpha = 0
        getData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.ambulanceMembershipCard)
    }
    
    func setupInterface() {
        title = NSLocalizedString("Your Membership", comment: "EplusMemberCardViewController title")
        if canTransitToInfo {
            let rightButton = UIBarButtonItem(image: UIImage(named: "info_button_icon"), style: .Done, target: self, action: Selector("showAboutController:"))
            navigationItem.rightBarButtonItem = rightButton
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector("closeTapped:"))
        }
    }
    
    
    func getData() {
        api().getMyProfile().flatMap { [weak self] (profile : UserProfile) -> Future<Void, NSError> in
            self?.profile = profile
            
            return api().getEPlusActiveMembership().flatMap { [weak self] (details : EplusMembershipDetails?) -> Future<Void, NSError> in
                guard let strongSelf = self, details = details else {
                    return Future()
                }
                strongSelf.planDetails = details
                
                return api().getEPlusMemberships().flatMap { [weak self] (response : CollectionResponse<EPlusMembershipPlan>) -> Future<Void, NSError> in
                    if let strongSelf = self, profile = strongSelf.profile {
                        strongSelf.plan = response.items.filter {$0.objectId == details.membershipPlanId}.first!
                        strongSelf.eplusMemberCardView?.configureWith(profile: profile, plan: strongSelf.plan!, membershipDetails: details)
                        strongSelf.detailsButton?.enabled = true

                        strongSelf.showEplusMemberCard()
                    }
                    return Future()
                }
            }
        }
    }
    
    private func showEplusMemberCard() {
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.eplusMemberCardView?.alpha = 1.0
            if !self.canTransitToInfo {
                self.setPlanDateRange()
                self.infoSectionViewContainer?.alpha = 1.0
            } else {
                //set height constraint to 0 in order for scroll place to be more narrow
                guard let infoSectionViewContainer = self.infoSectionViewContainer else { return }
                let heightConstraint =  NSLayoutConstraint(item: infoSectionViewContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.0)
                infoSectionViewContainer.addConstraint(heightConstraint)
            }
        })
        activityIndicator?.stopAnimating()
    
    }
    
    private func setPlanDateRange() {
        guard let startDate = planDetails?.startDate, endDate = planDetails?.endDate else {
            dateRangeLabel?.hidden = true
            return
        }

        let dateRangeString = dateFormatter.stringFromDate(startDate) + " - " + dateFormatter.stringFromDate(endDate)
        dateRangeLabel?.text = dateRangeString
    }

    
    //MARK: Targe-Action
    
    @IBAction func detailsTapped(sender: AnyObject) {
        if let plan = self.plan {
            router.showMembershipPlanDetailsViewController(from: self, with: plan, onlyPlanInfo: true)
        }
    }
    
    
    func closeTapped(sender: AnyObject) {
        self.router.dismissMembership(from: self)
    }
    
    func showAboutController(sender: AnyObject) {
        router.showAboutController(from: self)
    }
}