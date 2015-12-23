//
//  MembershipPlansViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 01/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class MembershipPlansViewController: UIViewController {

    override func viewDidLoad() {
        self.title = NSLocalizedString("Membership Plans", comment: "Membership")
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateChieldViewController(PlanType.Individual.rawValue)
    }
    
    func updateChieldViewController(index: Int) {
        parentViewController?.view.endEditing(true)
        if let currentController = currentModeViewController {
            currentController.willMoveToParentViewController(nil)
            currentController.view.removeFromSuperview()
            currentController.removeFromParentViewController()
        }
        
        if let childController = self.viewControllerForIndex(index) {
            childController.willMoveToParentViewController(self)
            self.addChildViewController(childController)
            
            self.contentView.addSubViewOnEntireSize(childController.view)
            currentModeViewController = childController
        }
    }

    func viewControllerForIndex(index: Int) -> UIViewController? {
        let controller = Storyboards.Onboarding.instantiatePlansViewController()
        if let planType = PlanType(rawValue: index) {
            controller.membershipType = planType
        }

        return controller
    }

    weak var currentModeViewController: UIViewController?
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.updateChieldViewController(sender.selectedSegmentIndex)
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var contentView: UIView!
}
