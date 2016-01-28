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
    
    private let mapping : [String : UIViewController]
    private let controllerTitle : String
    
    //MARK: Initializers
    
    init(mapping : [String : UIViewController], title : String) {
        assert(mapping.keys.count == 2)
        
        self.mapping = mapping
        self.controllerTitle = title
        super.init(nibName: String(SegmentedControlContainerViewController.self), containeredViewControllers: Array(mapping.values))
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
        let keys = Array(self.mapping.keys)
        self.segmentedControl.setTitle(keys[0], forSegmentAtIndex: 0)
        self.segmentedControl.setTitle(keys[1], forSegmentAtIndex: 1)
    }
    
    //MARK: Target-Action
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        self.activeIndex = self.segmentedControl.selectedSegmentIndex
    }
    
}
