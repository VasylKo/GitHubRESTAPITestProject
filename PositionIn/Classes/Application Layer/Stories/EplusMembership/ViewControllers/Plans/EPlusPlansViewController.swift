//
//  EPlusPlansViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusPlansViewController: UIViewController {
    
    init(router: EPlusMembershipRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(EPlusPlansViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupTableViewHeaderFooter()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTableViewHeaderFooter()
        self.loadData()
    }
    
    func loadData() {
        spinner.startAnimating()
        self.tableView.hidden = true
        self.buttonContainerView.hidden = true
        api().getEPlusMemberships().onSuccess(callback: { [weak self] (response : CollectionResponse<EPlusMembershipPlan>) in
            self?.plans = response.items
            self?.tableView.reloadData()
            self?.spinner.stopAnimating()
            self?.tableView.hidden = false
            self?.buttonContainerView.hidden = false
            }).onFailure(callback: {[weak self] _ in
                self?.spinner.stopAnimating()
            })
    }
    
    func setupUI() {
        self.title = "E-Plus"
        
        let topBorder: CALayer = CALayer()
        topBorder.borderColor = UIColor.bt_colorWithBytesR(233, g: 233, b: 233).CGColor
        topBorder.borderWidth = 1
        topBorder.frame = CGRectMake(-1, -1, CGRectGetWidth(buttonContainerView.frame) + 2, CGRectGetHeight(buttonContainerView.frame) + 2)
        buttonContainerView.layer.addSublayer(topBorder)
        
        self.tableView.estimatedRowHeight = 73
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let nib = UINib(nibName: String(EPlusPlanTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanTableViewCell.self))
        
        callAmbulanceButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        
    }
    
    func setupTableViewHeaderFooter() {
        let footerView = NSBundle.mainBundle().loadNibNamed(String(EPlusTableViewFooterView.self), owner: nil, options: nil).first
        if let footerView = footerView as? EPlusTableViewFooterView {
            footerView.delegate = self
            self.tableView.tableFooterView = footerView
        }
        
        let headerView = NSBundle.mainBundle().loadNibNamed(String(EPlusTableViewHeaderView.self), owner: nil, options: nil).first
        if let headerView = headerView as? UIView {
            self.tableView.tableHeaderView = headerView
        }
    }
    
    @IBAction func callAnAmbulance(sender: AnyObject) {
        router.showCallAmbulanceViewController(from: self)
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var callAmbulanceButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var callAnAmbulanceButton: UIButton!
    private var plans: [EPlusMembershipPlan] = []
    private let router : EPlusMembershipRouter
}

extension EPlusPlansViewController: EPlusTableViewFooterViewDelegate {
    func alreadyMemberButtonTouched() {
        
        let optionMenu = UIAlertController(title: nil, message: "Please contact our support", preferredStyle: .ActionSheet)
        
        let callSupport = UIAlertAction(title: "Call Support", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        let emailSupport = UIAlertAction(title: "Email Support", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        let visitWebsire = UIAlertAction(title: "Visit Website", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(callSupport)
        optionMenu.addAction(emailSupport)
        optionMenu.addAction(visitWebsire)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
}

extension EPlusPlansViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let plan = plans[indexPath.row]
        router.showMembershipConfirmDetailsViewController(from: self, with: plan)
    }
}

extension EPlusPlansViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanTableViewCell.self),
            forIndexPath: indexPath) as! EPlusPlanTableViewCell
        let plan = self.plans[indexPath.row]
        cell.planImageViewString = plan.membershipImageName
        cell.titleLabelString = plan.name
        cell.infoLabelString = plan.costDescription
        cell.accessoryType = .DisclosureIndicator
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
}