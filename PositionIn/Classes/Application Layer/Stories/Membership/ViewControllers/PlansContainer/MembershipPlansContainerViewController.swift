//
//  MembershipPlansContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipPlansContainerViewController : ContainerViewController {
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    private let router : MembershipRouter
    
    //MARK: Initializers
    
    init(router: MembershipRouter, containeredViewControllers : [UIViewController]) {
        self.router = router
        super.init(nibName: String(MembershipPlansContainerViewController.self), bundle: nil)
        self.containeredViewControllers = containeredViewControllers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    func setupInterface() {
        self.segmentControl.tintColor = UIScheme.mainThemeColor
    }
    
    //MARK: Target-Action
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        self.activeIndex = self.segmentControl.selectedSegmentIndex
    }
}
