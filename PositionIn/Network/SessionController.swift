//
//  SessionController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import KeychainAccess

struct SessionController {
    
    
    var accessToken: String? {
        return keychain[KeychainKeys.accessTokenKey]
    }
    
    var refreshToken: String? {
        return keychain[KeychainKeys.refreshTokenKey]
    }
    

    func setAuth(authResponse: APIService.AuthResponse) {
        let keychain = self.keychain
        keychain[KeychainKeys.accessTokenKey] = authResponse.accessToken
        keychain[KeychainKeys.refreshTokenKey] = authResponse.refreshToken
        let expiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(authResponse.expires!))
        keychain.set(NSKeyedArchiver.archivedDataWithRootObject(expiresIn), key: KeychainKeys.ExpireDateKey)
    }
    

    private var keychain: Keychain {
        return Keychain(service: KeychainKeys.serviceName)
    }

    private struct KeychainKeys {
        static let serviceName =  NSBundle.mainBundle().bundleIdentifier!
        static let accessTokenKey = "at"
        static let refreshTokenKey = "rt"
        static let ExpireDateKey = "ed"
    }
}