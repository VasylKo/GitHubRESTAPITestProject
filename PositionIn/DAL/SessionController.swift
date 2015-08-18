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
import CleanroomLogger

struct SessionController {
    
    func currentUserId() -> Future<CRUDObjectId, NSError> {
        return future { () -> Result<CRUDObjectId ,NSError> in
            if let userId = self.userIdValue {
                return Result(value: userId)
            } else {
                Log.warning?.trace()
                let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                return Result(error: errorCode.error())
            }
        }
    }
    
    func session() -> Future<APIService.AuthResponse.Token ,NSError> {
        return future { () -> Result<APIService.AuthResponse.Token ,NSError> in
            if  let token = self.accessToken,
                let expirationDate = self.expiresIn
                where expirationDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                    return Result(value: token)
            }
            Log.warning?.trace()
            let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
            return Result(error: errorCode.error())
        }
    }
    
    func logout() -> Future<Void, NoError> {
        return future {
            self.setAuth(APIService.AuthResponse.invalidAuth())
            self.setUserId(nil)
            return Result(value: ())
        }
    }
    
    func setAuth(authResponse: APIService.AuthResponse) {
        Log.info?.message("Auth changed")
        Log.debug?.value(authResponse)
        let keychain = self.keychain
        keychain[KeychainKeys.AccessTokenKey] = authResponse.accessToken
        keychain[KeychainKeys.RefreshTokenKey] = authResponse.refreshToken
        let expiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(authResponse.expires!))
        keychain.set(NSKeyedArchiver.archivedDataWithRootObject(expiresIn), key: KeychainKeys.ExpireDateKey)
    }
    
    func setUserId(userId : CRUDObjectId?) {
        keychain[KeychainKeys.UserIdKey] = userId
    }
    
    private var userIdValue: CRUDObjectId? {
        return keychain[KeychainKeys.UserIdKey]
    }
    
    private var accessToken: String? {
        return keychain[KeychainKeys.AccessTokenKey]
    }
    
    private var refreshToken: String? {
        return keychain[KeychainKeys.RefreshTokenKey]
    }
    
    private var expiresIn: NSDate? {
        if let data = keychain.getData(KeychainKeys.ExpireDateKey) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
        }
        return nil
    }
    
    private var keychain: Keychain {
        return Keychain()
    }

    private struct KeychainKeys {
        static let AccessTokenKey = "at"
        static let RefreshTokenKey = "rt"
        static let ExpireDateKey = "ed"
        
        static let UserIdKey = "userId"
    }
}