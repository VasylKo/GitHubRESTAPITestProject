//
//  PostToContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class PostToContainerViewController: ContainerViewController, XLFormRowDescriptorViewController {

    var rowDescriptor : XLFormRowDescriptor?
    var rowDescriptorViewControllers : [XLFormRowDescriptorViewController]?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let communitySearchViewController = CommunitySearchViewController()
        let volunteerSearchViewController = VolunteerSearchViewController()
        let containeredViewControllers = [communitySearchViewController, volunteerSearchViewController]
        rowDescriptorViewControllers = [communitySearchViewController, volunteerSearchViewController]
        super.init(nibName: String(PostToContainerViewController.self), containeredViewControllers: containeredViewControllers)
    }

    required init?(coder aDecoder: NSCoder) {
        let communitySearchViewController = CommunitySearchViewController()
        let volunteerSearchViewController = VolunteerSearchViewController()
        let containeredViewControllers = [communitySearchViewController, volunteerSearchViewController]
        rowDescriptorViewControllers = [communitySearchViewController, volunteerSearchViewController]
        super.init(nibName: String(PostToContainerViewController.self), containeredViewControllers: containeredViewControllers)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = rowDescriptor?.tag
        segmentedControl.tintColor = UIScheme.mainThemeColor
        for rowDescriptorViewController : XLFormRowDescriptorViewController in rowDescriptorViewControllers! {
            rowDescriptorViewController.rowDescriptor = rowDescriptor
        }
        activeIndex = segmentedControl.selectedSegmentIndex
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        activeIndex = self.segmentedControl.selectedSegmentIndex
    }
}
