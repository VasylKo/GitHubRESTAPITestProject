//
//  EPlusServiceDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 19/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class EPlusServiceDetailsViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let router : EPlusMembershipRouter
    private let service: EPlusService
    
    init(router: EPlusMembershipRouter, service: EPlusService) {
        self.router = router
        self.service = service
        super.init(nibName: NSStringFromClass(AboutEplusServiceController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewHeaderFooter()
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        setupTableViewHeaderFooter()
    }
    
    func setupUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        let nib = UINib(nibName: String(EPlusPlanInfoTableViewCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: String(EPlusPlanInfoTableViewCell.self))
        tableView.separatorStyle = .None
        tableView.bounces = false
    }
    
    func setupTableViewHeaderFooter() {
        let footerView = NSBundle.mainBundle().loadNibNamed(String(EPlusServisesTableViewFooter.self), owner: nil, options: nil).first
        if let footerView = footerView as? EPlusServisesTableViewFooter {
            if let note = self.service.footnote {
                footerView.infoLabelString = note
                tableView.tableFooterView = footerView
            }
            
        }
        
        let headerView = NSBundle.mainBundle().loadNibNamed(String(EPlusServisesTableViewHeader.self), owner: nil, options: nil).first
        if let headerView = headerView as? EPlusServisesTableViewHeader {
            headerView.titleString = service.name
            headerView.iconImageString = service.serviceImageName
            headerView.mainImageString = service.mainImageName
            tableView.tableHeaderView = headerView
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
}

extension EPlusServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EPlusServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0, let infoBlocks = service.infoBlocks, let title = infoBlocks[section - 1].title {
            return title
        }
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
            headerView.textLabel?.textColor = UIColor.redColor()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSectionsInTableView = 0
        if let _ = service.serviceDesc {
            numberOfSectionsInTableView++
        }
        
        if let infoBlocks = service.infoBlocks {
            numberOfSectionsInTableView += infoBlocks.count
        }
        
        return numberOfSectionsInTableView
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var numberOfRowsInSection = 0
        if section == 0 {
            if let _ = service.serviceDesc {
                numberOfRowsInSection = 1
            }
        }
        else {
            if section > 0, let infoBlocks = service.infoBlocks?[section - 1].infoBlocks {
                numberOfRowsInSection = infoBlocks.count
            }
        }
        return numberOfRowsInSection
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(EPlusPlanInfoTableViewCell.self),
            forIndexPath: indexPath) as! EPlusPlanInfoTableViewCell
        if indexPath.section == 0 {
            if let serviceDesc = service.serviceDesc {
                cell.planInfoString = serviceDesc
                cell.showBullet = false
            }
        }
        else {
            if let infoBlocks = service.infoBlocks, title = infoBlocks[indexPath.section - 1].infoBlocks?[indexPath.row] {
                cell.showBullet = (infoBlocks.count > 0)
                cell.planInfoString = title
            }
        }
        if let textLinks = service.textLinks {
            for textLink in textLinks {
                cell.infoLabel.delegate = self
                let range = (cell.infoLabel.text as? NSString)?.rangeOfString(textLink.title)
                if range?.location != NSNotFound {
                    switch textLink.type {
                    case .PhoneNumber:
                        cell.infoLabel.addLinkToPhoneNumber(textLink.title, withRange: range!)
                    case .Email:
                        cell.infoLabel.addLinkToURL(NSURL(string: "mailto://\(textLink.title)")!, withRange: range!)
                    case .Url:
                        cell.infoLabel.addLinkToURL(NSURL(string: "http://\(textLink.title)")!, withRange: range!)
                    }
                }
            }
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        // TODO: Need to handle url
        let email = "\(url.user!)@\(url.host!)"
        MailComposeViewController.presentMailControllerFrom(self, recipientsList: [email])
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        let trimmedString = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(trimmedString)")!)
    }
}
