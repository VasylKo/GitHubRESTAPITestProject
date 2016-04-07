//
//  CreateConversationContainerViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class CreateConversationContainerViewController: UIViewController {

    enum ControllerType: Int {
        case People
        case Community
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateChieldViewController(ControllerType.People)
        trackScreenToAnalytics(AnalyticsLabels.messagesNewChat)
    }
    
    func updateChieldViewController(index: ControllerType) {
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
    
    func viewControllerForIndex(index: ControllerType) -> UIViewController? {
        let controller: UIViewController
        switch index {
        case ControllerType.People:
            controller = Storyboards.Main.instantiateCreateUserConversationViewController()
        case ControllerType.Community:
            controller = Storyboards.Main.instantiateCreateCommunityConversationViewController()
        }
        
        return controller
    }
    
    weak var currentModeViewController: UIViewController?
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {

        if let controllerType = ControllerType(rawValue: sender.selectedSegmentIndex) {
            self.updateChieldViewController(controllerType)
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var contentView: UIView!
}
