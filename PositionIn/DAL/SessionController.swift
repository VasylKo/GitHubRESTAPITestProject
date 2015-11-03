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
    
    func currentUserId() -> CRUDObjectId? {
        return self.userIdValue
    }
    
    func currentUserId() -> Future<CRUDObjectId, NSError> {
        return future { () -> Result<CRUDObjectId, NSError> in
            guard let userId = self.userIdValue else {
                Log.warning?.trace()
                let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                return Result(error: errorCode.error())
            }
            return Result(value: userId)
        }
    }
    
    func currentRefreshToken() -> Future<AuthResponse.Token, NSError> {
        return future { () -> Result<AuthResponse.Token, NSError> in
            guard let refreshToken = self.refreshToken else {
                Log.warning?.trace()
                let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                return Result(error: errorCode.error())
            }
            return Result(value: refreshToken)
        }
    }
    
    func session() -> Future<AuthResponse.Token, NSError> {
        return future { () -> Result<AuthResponse.Token, NSError> in
            //TODO: check expiration date
            guard let token = self.accessToken,
                let expirationDate = self.expiresIn
                where  NSDate().compare(expirationDate) == NSComparisonResult.OrderedDescending
                else {
                    Log.warning?.trace()
                    let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                    return Result(error: errorCode.error())
            }

            return Result(value: token)
        }
    }
    
    func logout() -> Future<Void, NoError> {
        return future {
            self.setAuth(AuthResponse.invalidAuth())
            self.updateCurrentStatus(nil)
            return Result(value: ())
        }
    }
    
    func isUserAuthorized() -> Future<Void, NSError> {
        return self.currentUserId().flatMap { _ in
            return future { () -> Result<Void, NSError> in
                if self.isGuest {
                    let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                    return Result(error: errorCode.error())
                } else {
                    return Result(value: ())
                }
            }
        }
    }
    
    func isUserAuthorized() -> Bool {
        if let _: CRUDObjectId = currentUserId() {
            return !isGuest
        }
        return false
    }
    
    
    func setAuth(authResponse: AuthResponse) {
        Log.info?.message("Auth changed")
        Log.debug?.value(authResponse)
        let keychain = self.keychain
        let expires: Int = authResponse.expires!
        let accessToken = expires > 0 ? authResponse.accessToken : nil
        let refreshToken = expires > 0 ? authResponse.refreshToken : nil
        keychain[KeychainKeys.AccessTokenKey] = accessToken
        keychain[KeychainKeys.RefreshTokenKey] = refreshToken
        let expiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(expires))
        do  {
            try keychain.set(NSKeyedArchiver.archivedDataWithRootObject(expiresIn), key: KeychainKeys.ExpireDateKey)
        } catch let error {
            Log.error?.value(error)
        }
    }

    func updateCurrentStatus(profile: UserProfile?) {
        keychain[KeychainKeys.UserIdKey] = profile?.objectId
        var isGuest: Bool = profile?.guest ?? true
        do {
            try keychain.set(NSData(bytes: &isGuest, length: sizeof(Bool)), key: KeychainKeys.IsGuestKey)
        } catch let error {
            Log.error?.value(error)
        }
    }
    
    func updatePassword(newPassword: String) {
        keychain[KeychainKeys.UserPasswordKey] = newPassword
    }
    
    var userPassword: String? {
        return keychain[KeychainKeys.UserPasswordKey]
    }
    
    private var isGuest: Bool {
        do {
            if let data = try keychain.getData(KeychainKeys.IsGuestKey) {
                var isGuest: Bool = true
                data.getBytes(&isGuest, length:sizeof(Bool))
                return isGuest
            }
        } catch let error {
            Log.error?.value(error)
        }
        return true
    }
    
    private var userIdValue: CRUDObjectId? {
        return keychain[KeychainKeys.UserIdKey]
    }
    
    var accessToken: String? {
        return keychain[KeychainKeys.AccessTokenKey]
    }
    
    private var refreshToken: String? {
        return keychain[KeychainKeys.RefreshTokenKey]
    }
    
    private var expiresIn: NSDate? {
        do {
            if let data = try keychain.getData(KeychainKeys.ExpireDateKey) {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
            }
        } catch let error {
            Log.error?.value(error)
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
        static let IsGuestKey = "isGuest"
        static let UserPasswordKey = "UserPassword"
    }
}