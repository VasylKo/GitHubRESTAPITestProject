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
        self.navigationItem.titleView = searchbar
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func displayModeSegmentChanged(sender: UISegmentedControl) {
        if let displayMode = DisplayMode(rawValue: sender.selectedSegmentIndex) {
            mode = displayMode
        } else {
         fatalError("Unknown display mode in segment control")
        }
    }

    
    var mode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyMode(mode)
            }
        }
    }
    
    
    enum DisplayMode: Int, Printable {
        case Map = 0
        case List = 1
        
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
    
    @IBOutlet weak var displayModeSegmentedControl: UISegmentedControl!
    private func applyMode(mode: DisplayMode) {
        println("\(self.dynamicType) Apply: \(mode)")
        if let currentController = currentModeViewController {
            currentController.willMoveToParentViewController(nil)
            currentController.view.removeFromSuperview()
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
        displayModeSegmentedControl.selectedSegmentIndex = mode.rawValue
    }
    
    lazy var searchbar: SearchBar = {
        let vPadding: CGFloat = 5
        let frame = CGRect(
            x: 0,
            y: vPadding,
            width: self.view.bounds.width,
            height: self.navigationController!.navigationBar.bounds.height - 2 * vPadding
        )
        let searchBar = SearchBar(frame: frame)
        searchBar.backgroundColor = UIColor.redColor()
        return searchBar
    }()

}
