//
//  EPlusAmbulanceController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusAmbulanceController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupTableViewHeaderFooter()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupTableViewHeaderFooter()
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

    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var callAnAmbulanceButton: UIButton!
}

extension EPlusAmbulanceController: EPlusTableViewFooterViewDelegate {
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

extension EPlusAmbulanceController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EPlusAmbulanceController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //WARNING: hardcode
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanTableViewCell.self),
            forIndexPath: indexPath) as! EPlusPlanTableViewCell
        cell.accessoryType = .DisclosureIndicator
        cell.separatorInset = UIEdgeInsetsZero
        return cell
    }
}