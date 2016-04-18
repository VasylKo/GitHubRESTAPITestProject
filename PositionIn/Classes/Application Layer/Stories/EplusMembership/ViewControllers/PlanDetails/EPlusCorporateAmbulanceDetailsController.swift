//
//  EPlusCorporateAmbulanceDetailsController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusCorporateAmbulanceDetailsController: UIViewController {
    
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
        var nib = UINib(nibName: String(EPlusPlanInfoTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanInfoTableViewCell.self))
        
        nib = UINib(nibName: String(EPlusCorporatePlanOptionTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusCorporatePlanOptionTableViewCell.self))
        
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
            }
            tableView.tableHeaderView = headerView
        }
    }
    
    private var plan: EPlusMembershipPlan?
    private let router : EPlusMembershipRouter
    @IBOutlet weak var tableView: UITableView!
}

extension EPlusCorporateAmbulanceDetailsController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EPlusCorporateAmbulanceDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0, let plan = self.plan, let benefitGroups = plan.benefitGroups, let title = benefitGroups[section - 1].title {
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
            return benefitGroups.count + 1 //+1 for first section
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }
        else {
            return 20
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if let plan = self.plan, let planOptions = plan.planOptions {
                return planOptions.count
            }
        }
        else {
            if let plan = self.plan, let benefitGroups = plan.benefitGroups, let benefits = benefitGroups[section - 1].benefits {
                return benefits.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if (indexPath.section == 0) {
            let optionCell = tableView.dequeueReusableCellWithIdentifier(String(EPlusCorporatePlanOptionTableViewCell.self),
                forIndexPath: indexPath) as! EPlusCorporatePlanOptionTableViewCell
            if let plan = self.plan, let planOptions = plan.planOptions {
                let option = planOptions[indexPath.row]
                optionCell.planInfoString = option.costDescription
                let currencyFormatter = AppConfiguration().currencyFormatter
                currencyFormatter.maximumFractionDigits = 0
                optionCell.priceString = currencyFormatter.stringFromNumber(option.price ?? 0.0) ?? ""
                
                if let minParticipants = option.minParticipants, let maxParticipants = option.maxParticipants {
                    optionCell.peopleAmountString = String("\(minParticipants) - \(maxParticipants)")
                }
                else if let minParticipants = option.minParticipants {
                    let moreThatString = "More that"
                    let text = String("\(moreThatString) \(minParticipants)")
                    let attributedText = NSMutableAttributedString(string:text)
                    attributedText.addAttribute(NSFontAttributeName, value:UIFont(name: "Helvetica", size: 15)!,
                        range: (text as NSString).rangeOfString(moreThatString))
                    attributedText.addAttribute(NSFontAttributeName, value:UIFont(name: "Helvetica", size: 25)!,
                        range: (text as NSString).rangeOfString("\(minParticipants)"))
                    optionCell.attributedPeopleAmountString = attributedText
                }
            }
            
            cell = optionCell
        }
        else {
            let infoPlanCell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanInfoTableViewCell.self),
                forIndexPath: indexPath) as! EPlusPlanInfoTableViewCell
            if let plan = self.plan, let benefitGroups = plan.benefitGroups, let benefits = benefitGroups[indexPath.section - 1].benefits {
                infoPlanCell.planInfoString = benefits[indexPath.row]
            }
            cell = infoPlanCell
            
        }
        return cell
    }
}

extension EPlusCorporateAmbulanceDetailsController: EPlusSelectPlanTableViewFooterViewDelegate {
    func selectPlanTouched() {
        router.showMembershipConfirmDetailsViewController(from: self, with: plan!)
    }
}

