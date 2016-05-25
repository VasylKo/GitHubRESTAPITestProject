//
//  ThankYouViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 12/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController, ThankYouViewDelegate {
    
    // MARK: - Init
    
    init(router: GiveBloodRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(self.dynamicType), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: - UI
    
    func setupUI() {
        self.navigationItem.hidesBackButton = true
        
        let view = NSBundle.mainBundle().loadNibNamed("ThankYouView", owner: self, options: nil).first
        if let thankYouView =  view as? ThankYouView {
            self.thankYouView = thankYouView
            thankYouView.delegate = self
            self.view.addSubview(thankYouView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        thankYouView?.sizeToFit()
        let frame = thankYouView?.frame
        if var frame = frame {
            frame.origin = CGPointMake(10, 10)
            thankYouView?.frame = frame
        }
    }
    
    // MARK: - ThankYouViewDelegate
    
    func viewBloodCenters() {
        self.router.showGiveBloodCentersViewController(from: self)
    }
    
    // MARK: - Support
    private weak var thankYouView: ThankYouView?
    private let router : GiveBloodRouter
}
