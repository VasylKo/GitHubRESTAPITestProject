//
//  MembershipPlansViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipPlansViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let router : MembershipRouter
    private var plans : [MembershipPlan] = []
    private var currentMembershipPlan : MembershipPlan?
    private var type : MembershipPlan.PlanType
    private let reuseIdentifier = String(MembershipPlanTableViewCell.self)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var alreadyMemberButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var spaceBetweenBottomViewAndTableViewContstraint: NSLayoutConstraint!
    
    //MARK: Initializers
    
    init(router: MembershipRouter, type : MembershipPlan.PlanType, currentMembershipPlan : MembershipPlan?) {
        self.router = router
        self.type = type
        self.currentMembershipPlan = currentMembershipPlan
        super.init(nibName: String(MembershipPlansViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        
        api().getMemberships().onSuccess { [weak self] (response : CollectionResponse<MembershipPlan>) in
            self?.activityIndicator.stopAnimating()
            self?.plans = response.items.filter(){ $0.type == self?.type }
            self?.tableView.reloadData()
        }
    }
    
    func setupInterface() {
        let nib = UINib(nibName: String(MembershipPlanTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: self.reuseIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if self.currentMembershipPlan != nil {
            self.bottomView.hidden = true
            spaceBetweenBottomViewAndTableViewContstraint.constant = -self.bottomView.frame.size.height
        }
    }
    
    //MARK: UITableViewDelegate & UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasGuest = (self.currentMembershipPlan == nil)
        return hasGuest ? plans.count + 1 : plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! MembershipPlanTableViewCell
        let hasGuest = (self.currentMembershipPlan == nil)
        if hasGuest {
            if indexPath.row == 0 {
                //first cell is guest
                cell.configureAsGuest()
            } else {
                cell.configure(with: self.plans[indexPath.row - 1])
            }
        } else {
            cell.configure(with: self.plans[indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let hasGuest = (self.currentMembershipPlan == nil)
        if hasGuest {
            if indexPath.row == 0 {
                //first cell is guest
                self.router.dismissMembership(from: self)
            } else {
                self.router.showMembershipPlanDetailsViewController(from: self, with : self.plans[indexPath.row - 1], onlyPlanInfo: false)
            }
        } else {
            self.router.showMembershipPlanDetailsViewController(from: self, with : self.plans[indexPath.row], onlyPlanInfo: false)
        }
    }
    
    //MARK: Target-Action
    
    @IBAction func alreadyMemberPressed(sender: AnyObject) {
        self.router.dismissMembership(from: self)
    }
}
