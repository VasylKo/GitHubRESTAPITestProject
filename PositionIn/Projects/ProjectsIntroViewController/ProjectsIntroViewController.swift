//
//  ProjectsIntroViewController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/23/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

let projectsIntroShowedKey = "projectsIntroShowedKey"

class ProjectsIntroViewController: UIViewController {
    
    weak var browseGridDelegate: BrowseGridViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var bodyTextLabel: UILabel?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        setText()
        
    }

    private func setupInterface() {
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
                                                                  style: .Plain, target: self, action: "nextButtonTouched:")
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    private func setText() {
        let title = NSLocalizedString("Маке а difference, be a difference", comment: "Project intro title")
        let text = NSLocalizedString(
            "18 million people in Kenya are living in desolation due to poverty, drought, floods, poor health, malnutrition, lack of clean water & sanitation, education and much more.\n\nThrough various programmes, KRCS has increased community resilience through the strengthening, diversification and protection of livelihoods and assets.\n\nThe interventions have an integrated approach through programming for improved livelihoods with a holistic view of access to water, irrigation, agriculture and by extension, health. Stay up to date with our latest KRCS activities", comment: "Project intro text")
        
        titleLabel?.text = title
        bodyTextLabel?.text = text
    }
    
    // MARK: - Actions
    @IBAction func nextButtonTouched(sender: AnyObject) {
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
