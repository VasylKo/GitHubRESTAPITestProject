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
    private var type : MembershipPlan.PlanType
    private let reuseIdentifier = String(MembershipPlanTableViewCell.self)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var alreadyMemberButton: UIButton!
    
    //MARK: Initializers
    
    init(router: MembershipRouter, type : MembershipPlan.PlanType) {
        self.router = router
        self.type = type
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
        
        self.alreadyMemberButton.setTitleColor(UIScheme.mainThemeColor, forState: .Normal)
    }
    
    //MARK: UITableViewDelegate & UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // guest not a plan, add it (+1)
        return plans.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! MembershipPlanTableViewCell
        if indexPath.row == 0 {
            //first cell is guest
            cell.configureAsGuest()
        } else {
            cell.configure(with: self.plans[indexPath.row - 1])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.row == 0 {
            //route as guest
        } else {
            self.router.showMembershipPlanDetailsViewController(from: self, with : self.plans[indexPath.row - 1])
        }
    }
    
}
