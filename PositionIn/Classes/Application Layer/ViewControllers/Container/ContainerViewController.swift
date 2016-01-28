//
//  ContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class ContainerViewController: UIViewController {
    
    private let containeredViewControllers : [UIViewController]
    
    @IBOutlet weak var containerView : UIView?
    
    //MARK: Initializers
    
    init(nibName: String, containeredViewControllers : [UIViewController]) {
        self.containeredViewControllers = containeredViewControllers
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        assert(containerView != nil)
    }
    
    private var _activeIndex : Int = -1
    var activeIndex : Int {
        get {
            return _activeIndex
        }
        set {
            if (self.containeredViewControllers.count - 1 >= newValue) {
                self.currentViewController = self.containeredViewControllers[newValue]
                _activeIndex = newValue;
            } else {
                Log.error?.message("Unacceptable value of activeIndex: \(newValue))")
            }
        }
    }
    
    private var _currentViewController : UIViewController?
    var currentViewController : UIViewController {
        get {
            return _currentViewController!
        }
        set {
            if (_currentViewController != newValue) {
                if _currentViewController != nil {
                    _currentViewController!.view.removeFromSuperview()
                    _currentViewController!.removeFromParentViewController()
                }
                _currentViewController = newValue;
                
                self.addChildViewController(newValue)
                self.containerView!.addSubview(newValue.view)
                newValue.view.frame = CGRectMake(0, 0,
                    self.containerView!.frame.size.width,
                    self.containerView!.frame.size.height);
            }
        }
    }
    
}
