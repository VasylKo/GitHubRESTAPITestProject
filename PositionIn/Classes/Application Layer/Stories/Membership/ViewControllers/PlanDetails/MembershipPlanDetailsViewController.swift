//
//  MembershipPlanDetailsViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipPlanDetailsViewController: UIViewController, UITableViewDataSource {
    
    private let router : MembershipRouter
    private let plan: MembershipPlan
    private let reuseIdentifier = String(MembershipPlanDetailsBenefitTableViewCell.self)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var selectPlanButton: UIButton!
    @IBOutlet private weak var membershipPlanImageView: UIImageView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var membershipPlanTitleLabel: UILabel!
    
    //MARK: Initializers
    
    init(router: MembershipRouter, plan : MembershipPlan) {
        self.router = router
        self.plan = plan
        super.init(nibName: String(MembershipPlanDetailsViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
    }
    
    func setupInterface() {
        self.title = String("Membership Plans")
        
        self.membershipPlanImageView.image = UIImage(named : self.plan.membershipImageName)
        self.membershipPlanTitleLabel.text = self.plan.name
        self.priceLabel.text = String("KES \(self.plan.price ?? 0) Annually")
        
        self.tableView.registerNib(UINib(nibName: String(MembershipPlanDetailsBenefitTableViewCell.self), bundle: nil), forCellReuseIdentifier: self.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.plan.benefits?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! MembershipPlanDetailsBenefitTableViewCell
        
        if let benefit = self.plan.benefits?[indexPath.row] {
            cell.configure(with: benefit)
            cell.updateConstraintsIfNeeded()
        }
        
        return cell
    }
    
    //MARK: Target-Action
    
    @IBAction func selectPlanTapped(sender: AnyObject) {
        
    }
}
