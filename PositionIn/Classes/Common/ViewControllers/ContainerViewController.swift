//
//  ContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

public class ContainerViewController: UIViewController {
    
    public var containeredViewControllers : [UIViewController]?
    @IBOutlet weak var containerView : UIView?
    
    override public func viewDidLoad() {
        assert(containerView != nil)
        assert(containeredViewControllers != nil)
    }
    
    private var _activeIndex : Int = -1
    public var activeIndex : Int {
        get {
            return _activeIndex
        }
        set {
            if (self.containeredViewControllers!.count - 1 >= newValue) {
                self.currentViewController = self.containeredViewControllers![newValue]
                _activeIndex = newValue;
            } else {
                Log.error?.message("Unacceptable value of activeIndex: \(newValue))")
            }
        }
    }
    
    private var _currentViewController : UIViewController?
    public var currentViewController : UIViewController {
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
