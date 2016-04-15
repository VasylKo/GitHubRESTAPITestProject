//
//  EPlusAmbulanceDetailsController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusAmbulanceDetailsController: UIViewController {
    
    init(router: EPlusMembershipRouter, plan: EPlusMembershipPlan) {
        self.plan = plan
        self.router = router
        super.init(nibName: NSStringFromClass(EPlusAmbulanceDetailsController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewHeaderFooter()
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        setupTableViewHeaderFooter()
    }
    
    func setupUI() {
        title = "Rescue Package"
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        let nib = UINib(nibName: String(EPlusPlanInfoTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanInfoTableViewCell.self))
        tableView.separatorStyle = .None
        tableView.bounces = false
    }
    
    func setupTableViewHeaderFooter() {
        let footerView = NSBundle.mainBundle().loadNibNamed(String(EPlusSelectPlanTableViewFooterView.self), owner: nil, options: nil).first
        if let footerView = footerView as? EPlusSelectPlanTableViewFooterView {
            footerView.delegate = self
            tableView.tableFooterView = footerView
        }
        
        let headerView = NSBundle.mainBundle().loadNibNamed(String(EPlusAbulanceDetailsTableViewHeaderView.self), owner: nil, options: nil).first
        if let headerView = headerView as? EPlusAbulanceDetailsTableViewHeaderView {
            if let plan = plan {
                headerView.planImageViewString = plan.membershipImageName
                headerView.planNameString = plan.name
                headerView.priceString = plan.costDescription

            }
            tableView.tableHeaderView = headerView
        }
    }
    
    private var plan: EPlusMembershipPlan?
    private let router : EPlusMembershipRouter
    @IBOutlet weak var tableView: UITableView!
}

extension EPlusAmbulanceDetailsController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EPlusAmbulanceDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let plan = self.plan, let benefitGroups = plan.benefitGroups, let title = benefitGroups[section].title {
            return title
        }
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
            headerView.textLabel?.textColor = UIColor.bt_colorWithBytesR(169, g: 169, b: 169)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let plan = self.plan, let benefitGroups = plan.benefitGroups {
            return benefitGroups.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let plan = self.plan, let benefitGroups = plan.benefitGroups, let benefits = benefitGroups[section].benefits {
            return benefits.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanInfoTableViewCell.self),
            forIndexPath: indexPath) as! EPlusPlanInfoTableViewCell
        if let plan = self.plan, let benefitGroups = plan.benefitGroups, let benefits = benefitGroups[indexPath.section].benefits {
            cell.planInfoString = benefits[indexPath.row]
        }
        return cell
    }
}

extension EPlusAmbulanceDetailsController: EPlusSelectPlanTableViewFooterViewDelegate {
    func selectPlanTouched() {
        
    }
}
