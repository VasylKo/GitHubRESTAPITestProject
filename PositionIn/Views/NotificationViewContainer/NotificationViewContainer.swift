
//
//  NotificationViewContainer.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 17/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class NotificationViewContainer: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navigationBarHeight: CGFloat = 44
        
        var frame = UIScreen.mainScreen().bounds
        frame.origin.y = statusBarHeight + navigationBarHeight
        frame.size.height = frame.size.height - frame.origin.y
        self.frame = frame
        
        let notificationViewHeight : CGFloat = 40
        self.notificationView = NotificationView(frame: CGRectMake(0, -notificationViewHeight,
            self.frame.size.width, notificationViewHeight))
        notificationView?.title = "Test"
        notificationView?.type = .Yellow
        self.addSubview(notificationView!)
    }
    
    func show() {
        let window = UIApplication.sharedApplication().delegate?.window
        if let window = window {
            window?.addSubview(self)
            window?.bringSubviewToFront(self)
            
            
            UIView.animateWithDuration(1, animations: {
                var frame = self.notificationView?.frame
                frame?.origin.y = 0
                self.notificationView?.frame = frame!
                }, completion: { _ in
                    self.removeFromSuperview()
            })
        }
    }
    
    private var notificationView: NotificationView?
    
}
