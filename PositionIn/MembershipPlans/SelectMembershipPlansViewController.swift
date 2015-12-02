//
//  SelectMembershipPlansViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class SelectMembershipPlansViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let corporatePlan = self.corporatePlan {
            self.benefitsArray = CorporatePlans.benefits(corporatePlan)
            self.membershipImageView.image = CorporatePlans.corporateIconImage(corporatePlan)
            self.priceLabel.text = CorporatePlans.description(corporatePlan)
            self.membershipTitleLabel.text = CorporatePlans.title(corporatePlan)
        } else if let individualPlan = self.individualPlan {
            self.benefitsArray = IndividualPlans.benefits(individualPlan)
            self.membershipImageView.image = IndividualPlans.individualIconImage(individualPlan)
            self.priceLabel.text = IndividualPlans.description(individualPlan)
            self.membershipTitleLabel.text = IndividualPlans.title(individualPlan)
        }
        
        let reuseIdentifier = NSStringFromClass(MembershipBenefitCell.self)
        self.tableView.registerNib(UINib(nibName: reuseIdentifier,
            bundle: nil),
            forCellReuseIdentifier: reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        self.title = NSLocalizedString("Membership Plans", comment: "Membership")
    }
    
    @IBAction func selectPlanTapped(sender: AnyObject) {
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var corporatePlan: CorporatePlans?
    var individualPlan: IndividualPlans?
    var benefitsArray: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectPlanButton: UIButton!
    @IBOutlet weak var membershipImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var membershipTitleLabel: UILabel!
}

extension SelectMembershipPlansViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return benefitsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MembershipBenefitCell.self), forIndexPath: indexPath)
        
        if let cell = cell as? MembershipBenefitCell {
            let benefit = self.benefitsArray[indexPath.row]
            cell.benefitString = benefit
            cell.updateConstraintsIfNeeded()
        }
        return cell
    }
}
