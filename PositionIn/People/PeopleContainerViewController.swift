//
//  PeopleContainerViewController.swift
//  PositionIn
//
//  Created by ng on 3/22/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import CleanroomLogger

protocol PeopleActionConsumer {
    func showProfileScreen(userId: CRUDObjectId)
}

class PeopleContainerViewController : BesideMenuViewController {
    
    private let containeredViewControllers : [UIViewController]
    
    @IBOutlet private weak var containerView : UIView?
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    //MARK: Initializers

    required init?(coder: NSCoder) {
        self.containeredViewControllers = [PeopleFollowingViewController(), PeopleExploreViewController()]
        super.init(coder: coder)
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(self.containerView != nil)
        assert(self.segmentedControl.numberOfSegments == containeredViewControllers.count)
        
        activeIndex = self.segmentedControl.selectedSegmentIndex
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
    
    func switchToExploreViewController() {
        segmentedControl.selectedSegmentIndex = self.segmentedControl.numberOfSegments - 1
        activeIndex = segmentedControl.selectedSegmentIndex
    }
    
    //MARK: Target-Action
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        self.activeIndex = self.segmentedControl.selectedSegmentIndex
    }
    
}


extension PeopleContainerViewController: PeopleActionConsumer {
    
    func showProfileScreen(userId: CRUDObjectId) {
        let profileController = Storyboards.Main.instantiateUserProfileViewController()
        profileController.objectId = userId
        navigationController?.pushViewController(profileController, animated: true)
    }
    
}
