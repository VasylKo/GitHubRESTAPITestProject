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
    
    func currentRefreshToken() -> Future<AccessTokenResponse.Token, NSError> {
        return future { () -> Result<AccessTokenResponse.Token, NSError> in
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
            if let token = self.currentAccessToken() {
                return Result(value: token)
            } else {
                Log.warning?.trace()
                let errorCode = NetworkDataProvider.ErrorCodes.InvalidSessionError
                return Result(error: errorCode.error())
            }
        }
    }
    
    func currentAccessToken() -> AuthResponse.Token? {
        guard let token = self.accessToken,
            let expirationDate = self.accessTokenExpiresIn
            where  NSDate().compare(expirationDate) == NSComparisonResult.OrderedAscending
            else {
                return nil
        }
        return token
    }
    
    func currentDeviceToken() -> String? {
        guard let token = self.deviceToken
            else {
                return nil
        }
        return token
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
        let accessTokenExpires: Int = authResponse.accessTokenExpires!
        let refreshTokenExpires: Int = authResponse.refreshTokenExpires!
        
        let accessToken = accessTokenExpires > 0 ? authResponse.accessToken : nil
        let refreshToken = refreshTokenExpires > 0 ? authResponse.refreshToken : nil
        
        keychain[KeychainKeys.AccessTokenKey] = accessToken
        keychain[KeychainKeys.RefreshTokenKey] = refreshToken
        
        let accessTokenExpiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(accessTokenExpires))
        do  {
            try keychain.set(NSKeyedArchiver.archivedDataWithRootObject(accessTokenExpiresIn), key: KeychainKeys.AccessTokenKey)
        } catch let error {
            Log.error?.value(error)
        }
        
        let refreshTokenExpiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(refreshTokenExpires))
        do  {
            try keychain.set(NSKeyedArchiver.archivedDataWithRootObject(refreshTokenExpiresIn), key: KeychainKeys.ExpireDateKeyRT)
        } catch let error {
            Log.error?.value(error)
        }
    }
    
    func setAccessTokenResponse(accessTokenResponse: AccessTokenResponse) {
        Log.info?.message("AccessTokenResponse changed")
        Log.debug?.value(accessTokenResponse)
        let keychain = self.keychain
        let accessTokenExpires: Int = accessTokenResponse.accessTokenExpires!
        
        let accessToken = accessTokenExpires > 0 ? accessTokenResponse.accessToken : nil
        
        keychain[KeychainKeys.AccessTokenKey] = accessToken
        
        let accessTokenExpiresIn = NSDate(timeIntervalSinceNow: NSTimeInterval(accessTokenExpires))
        do  {
            try keychain.set(NSKeyedArchiver.archivedDataWithRootObject(accessTokenExpiresIn), key: KeychainKeys.ExpireDateKeyAT)
        } catch let error {
            Log.error?.value(error)
        }
    }
    
    func setDeviceToken(deviceToken: String?) {
        if let dt = deviceToken {
            do {
                try keychain.set(NSKeyedArchiver.archivedDataWithRootObject(dt),
                    key: KeychainKeys.DeviceToken)
            } catch let error {
                Log.error?.value(error)
            }
            
            keychain[KeychainKeys.DeviceToken] = dt
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
    
    @available(*, deprecated=1.0)
    func updatePassword(newPassword: String) {
        keychain[KeychainKeys.UserPasswordKey] = newPassword
    }
    
    @available(*, unavailable, message="We do not store password anymore")
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
    
    private var accessToken: String? {
        return keychain[KeychainKeys.AccessTokenKey]
    }
    
    private var refreshToken: String? {
        return keychain[KeychainKeys.RefreshTokenKey]
    }
    
    private var deviceToken: String? {
        return keychain[KeychainKeys.DeviceToken]
    }
    
    private var accessTokenExpiresIn: NSDate? {
        do {
            if let data = try keychain.getData(KeychainKeys.ExpireDateKeyAT) {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
            }
        } catch let error {
            Log.error?.value(error)
        }
        return nil
    }

    private var refreshTokenExpiresIn: NSDate? {
        do {
            if let data = try keychain.getData(KeychainKeys.ExpireDateKeyRT) {
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
        static let ExpireDateKeyAT = "edat"
        static let ExpireDateKeyRT = "edrt"
        
        static let UserIdKey = "userId"
        static let IsGuestKey = "isGuest"
        
        static let DeviceToken = "dt"
        
        @available(*, deprecated=1.0)
        static let UserPasswordKey = "UserPassword"
    }
}