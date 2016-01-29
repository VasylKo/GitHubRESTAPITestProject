//
//  SegmentedControlContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class SegmentedControlContainerViewController: ContainerViewController {
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private let labels : [String]
    private let controllerTitle : String
    
    //MARK: Initializers
    
    init(labels : [String], containeredViewControllers : [UIViewController], title : String) {
        assert(labels.count == containeredViewControllers.count)
        self.labels = labels
        self.controllerTitle = title
        super.init(nibName: String(SegmentedControlContainerViewController.self), containeredViewControllers: containeredViewControllers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        
        activeIndex = self.segmentedControl.selectedSegmentIndex
    }
    
    func setupInterface() {
        
        self.title = self.controllerTitle
        
        self.segmentedControl.tintColor = UIScheme.mainThemeColor
        
        for (index, value) in self.labels.enumerate() {
            self.segmentedControl.setTitle(value, forSegmentAtIndex: index)
        }
    }
    
    //MARK: Target-Action
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        self.activeIndex = self.segmentedControl.selectedSegmentIndex
    }
    
}
