//
//  IndividualMembershipPlans.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 01/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class PlansViewController: UIViewController {
    
    var membershipType: PlanType = .Individual
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reuseIdentifier = NSStringFromClass(MembershipPlansCell.self)
        self.tableView.registerNib(UINib(nibName: reuseIdentifier,
            bundle: nil),
            forCellReuseIdentifier: reuseIdentifier)
        
        self.tableView.rowHeight = 72
    }
    
    @IBOutlet weak var tableView: UITableView!
}

extension PlansViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == IndividualPlans.Guest.rawValue || indexPath.row == CorporatePlans.Guest.rawValue) {
            sideBarController?.executeAction(SidebarViewController.defaultAction)
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        let benefitsController = Storyboards.Onboarding.instantiateSelectMembershipPlansViewController()
        switch self.membershipType {
        case .Individual:
            benefitsController.individualPlan = IndividualPlans(rawValue: indexPath.row)
        case .Corporate:
            benefitsController.corporatePlan = CorporatePlans(rawValue: indexPath.row)
        }
        self.navigationController?.pushViewController(benefitsController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension PlansViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.membershipType {
        case .Individual:
            return IndividualPlans.count
        case .Corporate:
            return CorporatePlans.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MembershipPlansCell.self), forIndexPath: indexPath)
        
        if let cell = cell as? MembershipPlansCell {
            
            switch self.membershipType {
            case .Individual:
                if let individualPlan = IndividualPlans(rawValue: indexPath.row) {
                    cell.titleString = IndividualPlans.title(individualPlan)
                    cell.descriptionString = IndividualPlans.description(individualPlan)
                    cell.membershipIcon = IndividualPlans.individualIconImage(individualPlan)
                }
            case .Corporate:
                if let corporatePlans = CorporatePlans(rawValue: indexPath.row) {
                    cell.titleString = CorporatePlans.title(corporatePlans)
                    cell.descriptionString = CorporatePlans.description(corporatePlans)
                    cell.membershipIcon = CorporatePlans.corporateIconImage(corporatePlans)
                }
            }
        }
        return cell
    }
}
