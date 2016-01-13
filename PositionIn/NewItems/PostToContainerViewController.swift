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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let communitySearchViewController = CommunitySearchViewController()
        let volunteerSearchViewController = VolunteerSearchViewController()
        containeredViewControllers = [communitySearchViewController, volunteerSearchViewController]
        rowDescriptorViewControllers = [communitySearchViewController, volunteerSearchViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let communitySearchViewController = CommunitySearchViewController()
        let volunteerSearchViewController = VolunteerSearchViewController()
        containeredViewControllers = [communitySearchViewController, volunteerSearchViewController]
        rowDescriptorViewControllers = [communitySearchViewController, volunteerSearchViewController]
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
