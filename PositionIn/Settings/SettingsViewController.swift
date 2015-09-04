//
//  SettingsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class SettingsViewController: BesideMenuViewController {

    @IBAction func logoutTouched(sender: AnyObject) {
        api().logout().onComplete { [weak self] _ in
            self?.sideBarController?.executeAction(.Login)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = AppConfiguration().appVersion
    }
    
    @IBOutlet private weak var versionLabel: UILabel!
}
