//
//  MembershipPlansViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import MessageUI

class MembershipPlansViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    private let router : MembershipRouter
    private var plans : [MembershipPlan] = []
    private var currentMembershipPlan : MembershipPlan?
    private var type : MembershipPlan.PlanType
    private let reuseIdentifier = String(MembershipPlanTableViewCell.self)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var alreadyMemberButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var spaceBetweenBottomViewAndTableViewContstraint: NSLayoutConstraint!
    
    //TODO: should refactor
    let website = "http://www.redcross.or.ke"
    let phone = "+254703037000"
    let email = "membership@redcross.or.ke"
    
    //MARK: Initializers
    
    init(router: MembershipRouter, type : MembershipPlan.PlanType, currentMembershipPlan : MembershipPlan?) {
        self.router = router
        self.type = type
        self.currentMembershipPlan = currentMembershipPlan
        super.init(nibName: String(MembershipPlansViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        
        api().getMemberships().onSuccess { [weak self] (response : CollectionResponse<MembershipPlan>) in
            self?.activityIndicator.stopAnimating()
            self?.plans = response.items.filter(){ $0.type == self?.type }
            self?.tableView.reloadData()
        }
        
        let rightBarButtomItem = UIBarButtonItem(image: UIImage(named: "info_button_icon"), style: .Plain, target: self, action: "questionTapped")
        self.parentViewController?.navigationItem.rightBarButtonItem = rightBarButtomItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.membershipPlanSelection)
    }
    
    func setupInterface() {
        let nib = UINib(nibName: String(MembershipPlanTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: self.reuseIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if self.currentMembershipPlan != nil {
            self.bottomView.hidden = true
            spaceBetweenBottomViewAndTableViewContstraint.constant = -self.bottomView.frame.size.height
        }
    }
    
    //MARK: UITableViewDelegate & UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasGuest = (self.currentMembershipPlan == nil)
        return hasGuest ? plans.count + 1 : plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! MembershipPlanTableViewCell
        let hasGuest = (self.currentMembershipPlan == nil)
        if hasGuest {
            if indexPath.row == 0 {
                //first cell is guest
                cell.configureAsGuest()
            } else {
                cell.configure(with: self.plans[indexPath.row - 1])
            }
        } else {
            cell.configure(with: self.plans[indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let hasGuest = (self.currentMembershipPlan == nil)
        if hasGuest {
            if indexPath.row == 0 {
                //first cell is guest
                self.router.dismissMembership(from: self)
            } else {
                self.router.showMembershipPlanDetailsViewController(from: self, with : self.plans[indexPath.row - 1], onlyPlanInfo: false)
            }
        } else {
            self.router.showMembershipPlanDetailsViewController(from: self, with : self.plans[indexPath.row], onlyPlanInfo: false)
        }
    }
    
    //MARK: Target-Action
    
    @objc func questionTapped () {
        self.navigationController?.pushViewController(MembershipMessageController(nibName: "MembershipMessageController", bundle: nil),
                                                      animated: true)
    }
    
    @IBAction func alreadyMemberPressed(sender: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: NSLocalizedString("Please contact our support"), message: nil, preferredStyle: .ActionSheet)
        let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel"), style: .Cancel, handler: nil)
        actionSheetController.addAction(cancelActionButton)
        
        let callSupportTitle = NSLocalizedString("Call Support")
        let callAction: UIAlertAction = UIAlertAction(title: callSupportTitle, style: .Default)
            { action -> Void in
                trackGoogleAnalyticsEvent("Membership", action: "AlreadyMember", label: callSupportTitle)
                UIApplication.sharedApplication().openURL(NSURL(string:"telprompt:" + self.phone)!)
        }
        actionSheetController.addAction(callAction)
        
        let emailSupportTitle = NSLocalizedString("Email Support")
        let emailAction: UIAlertAction = UIAlertAction(title: emailSupportTitle, style: .Default)
            { action -> Void in
                trackGoogleAnalyticsEvent("Membership", action: "AlreadyMember", label: emailSupportTitle)
                let mailComposeViewController = self.configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
        }
        actionSheetController.addAction(emailAction)
        
        let visitWebTitle = NSLocalizedString("Visit Website")
        let websiteAction: UIAlertAction = UIAlertAction(title: visitWebTitle, style: .Default)
            { action -> Void in
                trackGoogleAnalyticsEvent("Membership", action: "AlreadyMember", label: visitWebTitle)
                let websiteURL = NSURL(string: "http://www.redcross.or.ke")!
                OpenApplication.Safari(with: websiteURL)
        }
        actionSheetController.addAction(websiteAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Private
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([self.email])
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("Could Not Send Email"),
            message: NSLocalizedString("Your device could not send e-mail.  Please check e-mail configuration and try again."),
            delegate: self,
            cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
}
