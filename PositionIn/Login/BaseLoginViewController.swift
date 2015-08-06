//
//  BaseLoginViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BaseLoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
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

}
