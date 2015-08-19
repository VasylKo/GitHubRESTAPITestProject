//
//  XMPPProcess+Future.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures
import Messaging

extension XMPPProcess {
    func future() -> Future<Void, NSError> {
        let p = Promise<Void, NSError>()
        let completion: XMPPProcesseCompletionBlock = { result, error in
            if let error = error {
                p.failure(error)
            } else {
                p.success(())
            }
        }
        executeWithCompletion(completion)
        return p.future
    }
}