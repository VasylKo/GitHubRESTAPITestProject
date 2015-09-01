//
//  BaseLoginViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class BaseLoginViewController: UIViewController {
    
    @IBAction func didTapClose(sender: AnyObject) {
        //Use existing session or register new
        api().session().recoverWith { _ in
            return api().register().flatMap { _ in
                return api().session()
            }
        }.onSuccess { [weak self] _ in
            Log.info?.message("Anonymous login done")
            self?.dismissLogin()
        }
    }
    
    func dismissLogin() {
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
    }


    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapOutsideTextFields:"))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromKeyboardNotifications()
    }
    
    func keyboardTargetView() -> UIView? {
        return nil
    }
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if let targetView = keyboardTargetView(),
           let info = notification.userInfo,
           let keyboardSizeValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            
            let keyboardSize = keyboardSizeValue.CGRectValue()
            var visibleRect = view.frame
            visibleRect.size.height -= keyboardSize.height
            let targetFrame = targetView.convertRect(targetView.bounds, toView: view)
            if !visibleRect.contains(targetFrame.origin) {
                let scrollPoint = CGPoint(x: 0, y: targetFrame.minY - visibleRect.height + targetFrame.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }

    func didTapOutsideTextFields(sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
}
