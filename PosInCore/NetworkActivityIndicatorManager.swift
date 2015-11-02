//
//  NetworkActivityIndicatorManager.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation


class NetworkActivityIndicatorManager {
    private var activityCount: Int
    private var activityIndicatorVisibilityTimer: NSTimer?
    
    var isNetworkActivityIndicatorVisible: Bool {
        return activityCount > 0
    }
    
    init() {
        activityCount = 0
    }
    
    func increment() {
        objc_sync_enter(self)
        activityCount++
        objc_sync_exit(self)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        }
    }
    
    func decrement() {
        objc_sync_enter(self)
        activityCount = max(activityCount - 1, 0)
        objc_sync_exit(self)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        }
    }
    
    private func updateNetworkActivityIndicatorVisibilityDelayed() {
        // Delay hiding of activity indicator for a short interval, to avoid flickering
        if (isNetworkActivityIndicatorVisible) {
            dispatch_async(dispatch_get_main_queue()) {
                self.updateNetworkActivityIndicatorVisibility()
            }
        } else {
            activityIndicatorVisibilityTimer?.invalidate()
            activityIndicatorVisibilityTimer = NSTimer(timeInterval: 0.2, target: self, selector: "updateNetworkActivityIndicatorVisibility", userInfo: nil, repeats: false)
            activityIndicatorVisibilityTimer!.tolerance = 0.2
            NSRunLoop.mainRunLoop().addTimer(activityIndicatorVisibilityTimer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    func updateNetworkActivityIndicatorVisibility() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = isNetworkActivityIndicatorVisible
    }
}