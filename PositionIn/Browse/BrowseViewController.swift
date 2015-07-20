//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BrowseViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyMode(mode)

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    var mode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyMode(mode)
            }
        }
    }
    
    
    enum DisplayMode: Printable {
        case Map
        case List
        
        var description: String {
            switch self {
            case .Map:
                return "Map browse mode"
            case .List:
                return "List browse mode"
            }
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    private weak var currentModeViewController: UIViewController?
    
    private func applyMode(mode: DisplayMode) {
        println("\(self.dynamicType) Apply: \(mode)")
        if let currentController = currentModeViewController {
            currentController.willMoveToParentViewController(nil)
            currentController.removeFromParentViewController()
        }
        
        let childController: UIViewController = {
            switch self.mode {
            case .Map:
                return Storyboards.Main.instantiateBrowseMapViewController()
            case .List:
                return Storyboards.Main.instantiateBrowseListViewController()
            }
        }()
        childController.willMoveToParentViewController(self)
        self.addChildViewController(childController)
        self.contentView.addSubview(childController.view)
        childController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views: [NSObject : AnyObject] = [ "childView": childController.view ]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[childView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[childView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))        
        childController.didMoveToParentViewController(self)
        currentModeViewController = childController
    }

}
