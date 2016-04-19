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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    func setupUI() {
        title = "Rescue Package"
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
            style: .Plain, target: self, action: "nextButtonTouched:")
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        let nib = UINib(nibName: String(EPlusPlanInfoTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanInfoTableViewCell.self))
        tableView.separatorStyle = .None
        tableView.bounces = false
    }
    
    private func sizeHeaderToFit() {
        guard let headerView = tableView?.tableHeaderView else { return }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
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
    
    func nextButtonTouched(sender: AnyObject) {
        router.showMembershipConfirmDetailsViewController(from: self, with: plan!)
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
        
        //Look if there is last section with additional benefits
        if let _ = plan?.otherBenefits where section == (tableView.numberOfSections - 1) {
            return "-------------------"
        } else if let benefitGroups = plan?.benefitGroups, let title = benefitGroups[section].title {
            return title
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIScheme.tableSectionTitleFont
            headerView.textLabel?.textColor = UIScheme.tableSectionTitleColor
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //There could be one section that is alway at the bottom
        if let plan = self.plan, let benefitGroups = plan.benefitGroups {
            let lastSection = plan.otherBenefits == nil ? 0 : 1
            return benefitGroups.count + lastSection
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //Look if there is last section with additional benefits
        if let lastSectionElements = plan?.otherBenefits where section == (tableView.numberOfSections - 1) {
            return lastSectionElements.count
        } else if let benefitGroups = plan?.benefitGroups, benefits = benefitGroups[section].infoBlocks {
            return benefits.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanInfoTableViewCell.self),
            forIndexPath: indexPath) as! EPlusPlanInfoTableViewCell
        
        //Look if there is last section with additional benefits
        if let lastSectionElements = plan?.otherBenefits where indexPath.section == (tableView.numberOfSections - 1) {
            cell.planInfoString = lastSectionElements[indexPath.row]
        } else if let benefitGroups = plan?.benefitGroups, let benefits = benefitGroups[indexPath.section].infoBlocks {
            cell.planInfoString = benefits[indexPath.row]
        }

        return cell
    }
}

extension EPlusAmbulanceDetailsController: EPlusSelectPlanTableViewFooterViewDelegate {
    func selectPlanTouched() {
        router.showMembershipConfirmDetailsViewController(from: self, with: plan!)
    }
}
