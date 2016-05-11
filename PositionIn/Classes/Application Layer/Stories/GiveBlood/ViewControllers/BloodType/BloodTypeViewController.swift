//
//  BloodTypeViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

enum BlodType: Int {
    case Unknown = 0, A, B, O, AB
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"),
                                                                 style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDone:")
        
        var view = NSBundle.mainBundle().loadNibNamed("BloodTypeView", owner: self, options: nil).first
        if let bloodTypeView =  view as? BloodTypeView {
            self.bloodTypeView = bloodTypeView
            self.view.addSubview(bloodTypeView)
        }
        
        view = NSBundle.mainBundle().loadNibNamed("DueDateView", owner: self, options: nil).first
        if let dueDateView =  view as? DueDateView {
            self.dueDateView = dueDateView
            self.view.addSubview(dueDateView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bloodTypeView?.sizeToFit()
        var frame = bloodTypeView?.frame
        if var frame = frame {
            frame.origin = CGPointMake(10, 10)
            bloodTypeView?.frame = frame
        }
        
        dueDateView?.sizeToFit()
        frame = dueDateView?.frame
        if var frame = frame, let bloodTypeViewFrame = bloodTypeView?.frame{
            frame.origin = CGPointMake(10, CGRectGetMaxY(bloodTypeViewFrame) + 8)
            dueDateView?.frame = frame
        }
    }
    
    @IBAction func didTapDone(sender: AnyObject) {

    }
    
    private var dueDateView: DueDateView?
    private var bloodTypeView: BloodTypeView?
    private let router : GiveBloodRouter
    
}
