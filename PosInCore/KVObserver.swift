//
//  KVObserver.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 17/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

@objc
public final class KVObserver<T>: NSObject {
    
    typealias ObserverBlock = (KVObserver, T?, T?) -> Void
    
    private(set) public var subject: AnyObject?
    private(set) public var keyPath: String
    private(set) public var block: ObserverBlock
    
    public init(subject: AnyObject, keyPath: String, block: ObserverBlock) {
        self.subject = subject
        self.keyPath = keyPath
        self.block = block
        super.init()
        subject.addObserver(self, forKeyPath: keyPath, options: .New | .Old, context: &KVObserverContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &KVObserverContext {
            let oldValue = change[NSKeyValueChangeOldKey] as? T
            let newValue = change[NSKeyValueChangeNewKey] as? T
            block(self, oldValue, newValue)
        } // NSObject does not implement observeValueForKeyPath
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

