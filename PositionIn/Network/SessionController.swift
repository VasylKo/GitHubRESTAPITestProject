//
//  SessionController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import KeychainAccess
import BrightFutures
import Result

struct SessionController {
    
    func session() -> Future<APIService.AuthResponse.Token ,NSError> {
        return future { () -> Result<APIService.AuthResponse.Token ,NSError> in
            if  let token = self.accessToken,
                let expirationDate = self.expiresIn
                where expirationDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                    return Result(value: token)
            }
            let errorCode = NetworkDataProvider.ErrorCodes.InvalidRequestError
            return Result(error: errorCode.error())
        }
    }
    
    private var accessToken: String? {
        return keychain[KeychainKeys.accessTokenKey]
    }
    
    private var refreshToken: String? {
        return keychain[KeychainKeys.refreshTokenKey]
    }
    
    private var expiresIn: NSDate? {
        if let data = keychain.getData(KeychainKeys.ExpireDateKey) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
        }
        return nil
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