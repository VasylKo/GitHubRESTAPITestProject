//
//  EPlusAmbulanceDetailsController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusAmbulanceDetailsController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupTableViewHeaderFooter()
        self.loadData()
    }
    
    func loadData() {
        spinner.startAnimating()
        self.tableView.hidden = true
        if let planId = planId {
            api().getAmbulanceMembership(planId).onSuccess(callback: { [weak self] plan in
                self?.tableView.reloadData()
            })
        }
    }
    
    func setupUI() {
        self.title = "Rescue Package"
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let nib = UINib(nibName: String(EPlusPlanTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanTableViewCell.self))
        
        callAmbulanceButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        
    }
    
    func setupTableViewHeaderFooter() {
        let footerView = NSBundle.mainBundle().loadNibNamed(String(EPlusSelectPlanTableViewFooterView.self), owner: nil, options: nil).first
        if let footerView = footerView as? EPlusSelectPlanTableViewFooterView {
            self.tableView.tableFooterView = footerView
        }
        
        let headerView = NSBundle.mainBundle().loadNibNamed(String(EPlusAbulanceDetailsTableViewHeaderView.self), owner: nil, options: nil).first
        if let headerView = headerView as? UIView {
            self.tableView.tableHeaderView = headerView
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var callAmbulanceButton: UIButton!
    private var plans: EplusMembershipPlan?
    var planId: String?
    
    @IBOutlet weak var tableView: UITableView!
}

extension EPlusAmbulanceDetailsController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EPlusAmbulanceDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
