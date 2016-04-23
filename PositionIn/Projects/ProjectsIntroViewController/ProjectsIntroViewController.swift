//
//  ProjectsIntroViewController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/23/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class ProjectsIntroViewController: UIViewController {
    
    weak var browseGridDelegate: BrowseGridViewControllerDelegate?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        
    }

    private func setupInterface() {
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
                                                                  style: .Plain, target: self, action: "nextButtonTouched:")
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    // MARK: - Actions
    @objc func nextButtonTouched(sender: AnyObject) {
        showProjectsList()
    }
    
    private func showProjectsList() {
        if let delegate = browseGridDelegate {
            delegate.browseGridViewControllerSelectItem(HomeItem.Projects)
        } else {
            fatalError("Set browseGridDelegate")
        }
    }

}
