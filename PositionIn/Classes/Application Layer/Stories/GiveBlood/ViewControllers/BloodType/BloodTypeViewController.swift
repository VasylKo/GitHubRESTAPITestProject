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
        super.init(nibName: NSStringFromClass(self.dynamicType), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Your Details", comment: "Title of give blood selection screen")
        api().getDonorInfo().onSuccess(callback: { [weak self] donorInfo in
            self?.donorInfo = donorInfo
            self?.activirtIndicator.hidden = true
            self?.setupUI()
            })
    }
    
    // MARK: - UI
    
    func setupUI() {
        
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"),
                                                                 style: .Plain, target: self, action: #selector(didTapDone(_:)))
        
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
        
        if let donorInfo = donorInfo {
            if let bloodGroup = donorInfo.bloodGroup where bloodGroup != .Unknown {
                self.bloodTypeView?.bloodGroup = bloodGroup
            }
            
            if let dueDate = donorInfo.dueDate {
                self.dueDateView?.dueDate = dueDate
            }
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
    
    // MARK: - Actions
    
    @IBAction func didTapDone(sender: AnyObject) {
        guard let bloodGroup = self.bloodTypeView?.bloodGroup
            else {
                showWarning(NSLocalizedString("Please select your blood type"))
                return
        }
        
        donorInfo?.bloodGroup = bloodGroup
        donorInfo?.dueDate = self.dueDateView?.dueDate
        donorInfo?.donorStatus = .Agreed
        if let donorInfo = donorInfo {
            api().updateDonorInfo(donorInfo).onSuccess(callback: {[unowned self] in
                self.router.showThankYouViewController(from: self)
                })
        }
    }
    
    private var donorInfo: DonorInfo?
    private var dueDateView: DueDateView?
    private var bloodTypeView: BloodTypeView?
    private let router : GiveBloodRouter
    @IBOutlet weak var activirtIndicator: UIActivityIndicatorView!
}
