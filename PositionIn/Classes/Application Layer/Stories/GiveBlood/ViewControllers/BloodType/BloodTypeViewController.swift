//
//  BloodTypeViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

enum BlodType {
    case Unknown, A, B, O, AB
}

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
        setupUI()
    }
    
    func setupUI() {
        let view = NSBundle.mainBundle().loadNibNamed("BloodTypeView", owner: self, options: nil).first
        if let bloodTypeView =  view as? BloodTypeView {
            self.bloodTypeView = bloodTypeView
            bloodTypeView.layer.shadowColor = UIColor.blackColor().CGColor
            bloodTypeView.layer.shadowOffset = CGSizeMake(0, 2);
            bloodTypeView.layer.shadowOpacity = 0.1
            bloodTypeView.layer.shadowRadius = 1.0;
            bloodTypeView.layer.masksToBounds = false
            bloodTypeView.layer.shadowOpacity = 0.1
            bloodTypeView.layer.cornerRadius = 3
            self.view.addSubview(bloodTypeView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bloodTypeView?.sizeToFit()
        let frame = bloodTypeView?.frame
        if var frame = frame {
            frame.origin = CGPointMake(10, 10)
            bloodTypeView?.frame = frame
        }
    }
    
    private var bloodTypeView: BloodTypeView?
    private let router : GiveBloodRouter
    
}
