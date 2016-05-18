
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
        self.notificationView = NSBundle.mainBundle().loadNibNamed(String(NotificationView.self), owner: self, options: nil).first as? NotificationView
        self.notificationView?.frame = (frame: CGRectMake(0, -notificationViewHeight, self.frame.size.width, notificationViewHeight))
        self.addSubview(notificationView!)
    }
    
    func show(title title: String?, type: NotificationViewType?) {
        
        notificationView?.title = title
        notificationView?.type = type
        
        self.layer.masksToBounds = true
        
        let window = UIApplication.sharedApplication().delegate?.window
        if let window = window {
            let view = window?.subviews.last
            var animated = true
            if (view as? NotificationViewContainer) != nil {
                animated = false
            }
            
            window?.addSubview(self)
            window?.bringSubviewToFront(self)
            
            let animationDutation = 1.5
            let showAnimationDuration = animated ? animationDutation: 0
            UIView.animateWithDuration(showAnimationDuration, animations: {
                var frame = self.notificationView?.frame
                frame?.origin.y = 0
                self.notificationView?.frame = frame!
                }, completion: { _ in
                    UIView.animateWithDuration(animationDutation, animations: {
                        var frame = self.notificationView?.frame
                        frame?.origin.y = -(self.notificationView?.frame.size.height)!
                        self.notificationView?.frame = frame!
                        }, completion: { _ in
                            self.removeFromSuperview()
                    })
            })
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }
    
    private var notificationView: NotificationView?
    
}
