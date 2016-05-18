//
//  EPlusAmbulanceDetailsController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusAmbulanceDetailsController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var plan: EPlusMembershipPlan?
    private let router : EPlusMembershipRouter
    private var onlyPlanInfo: Bool
    
    init(router: EPlusMembershipRouter, plan: EPlusMembershipPlan, onlyPlanInfo: Bool) {
        self.plan = plan
        self.router = router
        self.onlyPlanInfo = onlyPlanInfo
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.ambulanceMembershipPlanDetails)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderFooterToFit()
    }
    
    func setupUI() {
        title = "Rescue Package"
        
        if !onlyPlanInfo {
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
                style: .Plain, target: self, action: "nextButtonTouched:")
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
            
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        //General cell
        var nib = UINib(nibName: String(EPlusPlanInfoTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanInfoTableViewCell.self))
        
        //Corporare cell
        nib = UINib(nibName: String(EPlusCorporatePlanOptionTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusCorporatePlanOptionTableViewCell.self))
        
        //SpecialOfferSection cell
        nib = UINib(nibName: String(EPlusFtooterSectionTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusFtooterSectionTableViewCell.self))
        
        //SpecialOfferSection header
        nib = UINib(nibName: String(EPlusAbulanceDetailsTableViewSectionHeaderView.self), bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: String(EPlusAbulanceDetailsTableViewSectionHeaderView.self))
        
        
        tableView.separatorStyle = .None
        tableView.bounces = false
    }
    
    private func sizeHeaderFooterToFit() {
        guard let headerView = tableView?.tableHeaderView, footerView = tableView?.tableFooterView else { return }
        
        //Adjust header
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        var height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
        
        //Adjust footer
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        height = footerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        frame = footerView.frame
        frame.size.height = onlyPlanInfo ? 0 : height
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
    }
    
    func setupTableViewHeaderFooter() {
        let headerView = NSBundle.mainBundle().loadNibNamed(String(EPlusAbulanceDetailsTableViewHeaderView.self), owner: nil, options: nil).first
        if let headerView = headerView as? EPlusAbulanceDetailsTableViewHeaderView {
            if let plan = plan {
                headerView.planImageViewString = plan.membershipImageName
                headerView.planNameString = plan.name
                if plan.type != .Corporate {
                    headerView.priceString = plan.costDescription   
                }
            }
            tableView.tableHeaderView = headerView
        }
        
        let footerView = NSBundle.mainBundle().loadNibNamed(String(EPlusSelectPlanTableViewFooterView.self), owner: nil, options: nil).first
        if let footerView = footerView as? EPlusSelectPlanTableViewFooterView {
            footerView.delegate = self
            tableView.tableFooterView = footerView
        }
    }
    
    func nextButtonTouched(sender: AnyObject) {
        router.showMembershipConfirmDetailsViewController(from: self, with: plan!)
    }
}

    //MARK: - Sections Managment
extension EPlusAmbulanceDetailsController {
   
    private enum SectionType {
        case CorporateSection, GeneralSections (sectionIndex: Int), SpecialOfferSection, Unknown
    }
    
    private func getSectionType(sectionIndex: Int) -> SectionType {
        guard let plan = plan else { return .Unknown }
        
        if let _ = plan.planOptions where sectionIndex == 0 {
            return .CorporateSection
        } else if let _ = plan.otherBenefits where sectionIndex == (tableView.numberOfSections - 1) {
            return .SpecialOfferSection
        } else if let _ = plan.benefitGroups {
            let corporateSection = plan.planOptions == nil ? 0 : 1
            let correctedSectionNumber = sectionIndex - corporateSection
            return .GeneralSections (sectionIndex: correctedSectionNumber)
        }
        
        return .Unknown
    }
}

extension EPlusAmbulanceDetailsController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension EPlusAmbulanceDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let plan = plan else { return "" }
        
        let sectionType = getSectionType(section)
        
        switch sectionType {
        case .CorporateSection:
            return ""
            
        case .GeneralSections (let sectionIndex):
            let benefitGroups = plan.benefitGroups!
            let title = benefitGroups[sectionIndex].title
            return title
        
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = getSectionType(section)
        
        switch sectionType {
        case .CorporateSection:
            return 0
            
        case .GeneralSections:
            return 30
            
        case .SpecialOfferSection:
            return 10
            
        default:
            return 30
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionType = getSectionType(section)
        
        switch sectionType {
        case .SpecialOfferSection:
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(String(EPlusAbulanceDetailsTableViewSectionHeaderView.self))
            return headerView
            
        default:
            return nil
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIScheme.tableSectionTitleFont
            headerView.textLabel?.textColor = UIScheme.tableSectionTitleColor
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let plan = plan else { return 0 }
        
        let corporateSection = plan.planOptions == nil ? 0 : 1
        let lastSection = plan.otherBenefits == nil ? 0 : 1
        let GeneralSectionss = plan.benefitGroups?.count ?? 0
        
        return corporateSection + GeneralSectionss + lastSection
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        guard let plan = plan else { return 0 }
        
        let sectionType = getSectionType(section)
        
        switch sectionType {
        case .CorporateSection:
            let rowsCount = plan.planOptions!.count
            return rowsCount
            
        case .GeneralSections(let sectionIndex):
            let rowsCount = plan.benefitGroups![sectionIndex].infoBlocks?.count ?? 0
            return rowsCount
            
        case .SpecialOfferSection:
            let rowsCount = plan.otherBenefits!.count
            return rowsCount
            
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let plan = plan else { return UITableViewCell() }
        
        let sectionType = getSectionType(indexPath.section)
        
        switch sectionType {
        case .CorporateSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusCorporatePlanOptionTableViewCell.self), forIndexPath: indexPath) as! EPlusCorporatePlanOptionTableViewCell
            configureCorporateCell(cell, atIndexPath: indexPath)
            return cell
            
        case .GeneralSections(let sectionIndex):
            let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanInfoTableViewCell.self),
                forIndexPath: indexPath) as! EPlusPlanInfoTableViewCell
            
            if let benefits = plan.benefitGroups![sectionIndex].infoBlocks {
                cell.planInfoString = benefits[indexPath.row]
            }
            
            return cell
            
        case .SpecialOfferSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusFtooterSectionTableViewCell.self), forIndexPath: indexPath) as! EPlusFtooterSectionTableViewCell
            cell.titleLabel?.text = plan.otherBenefits![indexPath.row]
            return cell
            
        default:
            return UITableViewCell()
        }

    }
    
    //MARK: - Configure cells helper
    private func configureCorporateCell(cell: EPlusCorporatePlanOptionTableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let plan = self.plan, let planOptions = plan.planOptions {
            let option = planOptions[indexPath.row]
            cell.planInfoString = option.costDescription
            let currencyFormatter = AppConfiguration().currencyFormatter
            currencyFormatter.maximumFractionDigits = 0
            cell.priceString = currencyFormatter.stringFromNumber(option.price ?? 0.0) ?? ""
            
            if let minParticipants = option.minParticipants, let maxParticipants = option.maxParticipants {
                cell.peopleAmountString = String("\(minParticipants) - \(maxParticipants)")
            }
            else if let minParticipants = option.minParticipants {
                let moreThatString = "More than"
                let text = String("\(moreThatString) \(minParticipants)")
                let attributedText = NSMutableAttributedString(string:text)
                attributedText.addAttribute(NSFontAttributeName, value: UIScheme.appRegularFontOfSize(15),
                    range: (text as NSString).rangeOfString(moreThatString))
                attributedText.addAttribute(NSFontAttributeName, value: UIScheme.appRegularFontOfSize(25),
                    range: (text as NSString).rangeOfString("\(minParticipants)"))
                cell.attributedPeopleAmountString = attributedText
            }
        }
    }
    
    
}

extension EPlusAmbulanceDetailsController: EPlusSelectPlanTableViewFooterViewDelegate {
    func selectPlanTouched() {
        router.showMembershipConfirmDetailsViewController(from: self, with: plan!)
    }
}
