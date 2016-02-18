//
//  BarButtonItemContainerViewController.swift
//  PositionIn
//
//  Created by ng on 2/18/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class BarButtonItemContainerViewController: ContainerViewController {
    
    private let controllerTitle : String
    private var barButtonItems : [UIBarButtonItem] = []
    
    //MARK: Initializers
    
    init(containeredViewControllers : [UIViewController], title : String, imageNames : [String]) {
        assert(imageNames.count == containeredViewControllers.count)
        
        self.controllerTitle = title
        
        super.init(nibName: String(BarButtonItemContainerViewController.self), containeredViewControllers: containeredViewControllers)
        
        for imageName in imageNames {
            let barButtonItem : UIBarButtonItem  = UIBarButtonItem(image: UIImage(named: imageName), style: .Plain, target: self, action: Selector("barButtonPressed:"))
            self.barButtonItems.append(barButtonItem)
        }
        
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.barButtonItems[0]
        self.activeIndex = 0
    }
    
    //MARK: Target-Action
    
    func barButtonPressed(barButtonItem : UIBarButtonItem) {
        let index = self.barButtonItems.indexOf(barButtonItem)!
        let next = (index + 1 != self.barButtonItems.count) ? index + 1 : 0
        
        self.navigationItem.setRightBarButtonItem(self.barButtonItems[next], animated: true)
        
        self.activeIndex = next
    }
}