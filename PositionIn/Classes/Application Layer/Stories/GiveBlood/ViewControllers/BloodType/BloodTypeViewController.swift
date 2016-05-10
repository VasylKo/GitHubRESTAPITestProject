//
//  BloodTypeViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class BloodTypeViewController: UIViewController {
        
    // MARK: - Init
    init(router: GiveBloodRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(BloodTypeViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private let router : GiveBloodRouter

}
