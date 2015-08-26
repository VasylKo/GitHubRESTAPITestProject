//
//  FoundationWrappers.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

/**
Objective-C synchronised

:param: lock    lock object
:param: closure closure
*/
public func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/**
GCD dispatch after wrapper

:param: delay   delay in seconds
:param: queue   dispatch queue
:param: closure block
*/
public func dispatch_delay(delay:Double, queue:dispatch_queue_t, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        queue, closure)
}

/**
GCD dispatch after wrapper. Using main queue

:param: delay   delay in seconds
:param: closure block
*/
public func dispatch_delay(delay:Double, closure:()->()) {
    dispatch_delay(delay, dispatch_get_main_queue(), closure)
}


extension Array {
    /**
    Safe index subscript
    
    :param: safe index
    
    :returns: optional object
    */
    internal subscript (safe index: Int) -> Element? {
        return indices(self) ~= index
            ? self[index]
            : nil
    }
}

public  extension NSDictionary {
    /**
    Returns json representation
    
    :returns: JSON string
    */
    public func jsonString() -> String {
        if  NSJSONSerialization.isValidJSONObject(self),
            let data = NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions(), error: nil),
            let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return string as String
        }
        return ""
    }
    
}

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public extension UIView {
    /**
    Add subview to the reciever and install constraints to fill parent size
    
    :param: contentView subview
    */
    public func addSubViewOnEntireSize(contentView: UIView) {
        addSubview(contentView)
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views: [NSObject : AnyObject] = [ "contentView": contentView ]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        setNeedsLayout()        
    }
}