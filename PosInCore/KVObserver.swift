//
//  KVObserver.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 17/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation


public final class KVObserver<T>: NSObject {
    
    /// Observe closure - observer, old value, new value
    public typealias ObserverClosure = (KVObserver, T?, T?) -> Void
    
    private(set) public var subject: AnyObject?
    private(set) public var keyPath: String
    private(set) public var block: ObserverClosure
    
    public init(subject: AnyObject, keyPath: String, closure: ObserverClosure) {
        self.subject = subject
        self.keyPath = keyPath
        block = closure
        super.init()
        subject.addObserver(self, forKeyPath: keyPath, options: [.New, .Old], context: &KVObserverContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &KVObserverContext else {
            return
        } // NSObject does not implement observeValueForKeyPath
        

        let oldValue = change?[NSKeyValueChangeOldKey] as? T
        let newValue = change?[NSKeyValueChangeNewKey] as? T
        block(self, oldValue, newValue)
    }
    
    func stopObservation() {
        subject?.removeObserver(self, forKeyPath: keyPath, context: &KVObserverContext)
        subject = nil
    }
    
    deinit {
        stopObservation()
    }
    
    private var KVObserverContext = 0
}

