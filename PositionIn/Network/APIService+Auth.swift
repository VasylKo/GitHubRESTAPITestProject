//
//  NetworkDataProvider+Profile.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import Alamofire
import ObjectMapper
import BrightFutures
import CleanroomLogger
import Messaging

extension APIService {
    
    //Returns current user id
    func currentUserId() -> CRUDObjectId? {
        return sessionController.currentUserId()
    }
    
    //Returns current user id
    func currentUserId() -> Future<CRUDObjectId, NSError> {
        return sessionController.currentUserId()
    }
    
    //Returns true if user is registered
    func isUserAuthorized() -> Bool {
        return sessionController.isUserAuthorized()
    }
    
    //Success if user is registered
    func isUserAuthorized() -> Future<Void, NSError> {
        return handleFailure(sessionController.isUserAuthorized())
    }
    
    //Returns true if it is current user
    func isCurrentUser(userId: CRUDObjectId) -> Bool {
        if let currentUserId = api().currentUserId() {
            return currentUserId == userId
        }
        return false
    }
    
    func chatCredentialsProvider() -> XMPPCredentialsProvider {
        class ChatCredentialsProvider: NSObject, XMPPCredentialsProvider {
            init(apiService: APIService) {
                self.apiService = apiService
                super.init()
            }
            @objc func getChatCredentials() -> XMPPCredentials? {
                let userId: CRUDObjectId? = apiService.currentUserId()
                let userPassword = apiService.sessionController.userPassword
                switch (userId, userPassword) {
                case (.Some(let user), .Some(let password)):
                    let hostname = AppConfiguration().xmppHostname
                    let jid = "\(user)@\(hostname)"
                    return XMPPCredentials(jid: jid, password: password)
                default:
                    return nil
                }
            }
            
            private let apiService: APIService
        }
        return ChatCredentialsProvider(apiService: self)
    }
    
    //Success if has valid session and user is not a guest
    func recoverSession() -> Future<UserProfile, NSError> {
        let f = session().flatMap { _ in
            return self.sessionController.isUserAuthorized()
        }
        return handleFailure(f).flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    // Success on existing session or after token refresh
    func session() -> Future<AuthResponse.Token, NSError> {
        return sessionController.session().recoverWith { _ in
            return self.refreshToken().map { response in
                return response.accessToken
            }
        }
    }
    
    // Logout from the current session
    func logout() -> Future<Void, NoError> {
        return sessionController.logout().onComplete { _ in
            self.sendUserDidChangeNotification(nil)
        }
    }
    
    
    //Login existing user
    func login(#username: String, password: String) -> Future<UserProfile, NSError> {
        return loginRequest(username: username, password: password).flatMap { _ in
            return self.updateCurrentProfileStatus(newPasword: password)
        }
    }
    
    //Login via fb
    func login(fbToken: String) -> Future<UserProfile, NSError> {
        return facebookLoginRequest(fbToken).flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    //Register anonymous user
    func register() -> Future<UserProfile, NSError> {
        return registerRequest(username: nil, password: nil, info: nil).flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    //Register new user
    func register(#username: String, password: String, firstName: String?, lastName: String?) -> Future<UserProfile, NSError> {
        var info: [String: AnyObject] = [:]
        if let firstName = firstName {
            info ["firstName"] = firstName
        }
        if let lastName = lastName {
            info ["lastName"] = lastName
        }
        return registerRequest(username: username, password: password, info: info).flatMap { _ in
            return self.updateCurrentProfileStatus(newPasword: password)
        }
    }
    
    //MARK: - Private members -
    
    
    private func registerRequest(#username: String?, password: String?, info: [String: AnyObject]?) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Register(api: self, username: username, password: password, profileInfo: info)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.objectRequest(urlRequest)
        return handleFailure(updateAuth(future))
    }
    
    private func loginRequest(#username: String, password: String) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Login(api: self, username: username, password: password)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.objectRequest(urlRequest)
        return handleFailure(updateAuth(future))
    }
    
    private func facebookLoginRequest(fbToken: String) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Facebook(api: self, fbToken: fbToken)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.objectRequest(urlRequest)
        return handleFailure(updateAuth(future))
    }
    
    private func refreshToken() -> Future<AuthResponse, NSError> {
        return sessionController.currentRefreshToken().flatMap { (token: AuthResponse.Token) -> Future<AuthResponse, NSError> in
            let urlRequest = AuthRouter.Refresh(api: self, token: token)
            let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = self.dataProvider.objectRequest(urlRequest)
            return self.updateAuth(future)
        }
    }
    
    private func updateCurrentProfileStatus(newPasword: String? = nil) -> Future<UserProfile, NSError> {
        return getMyProfile().andThen { result in
            if let profile = result.value {
                self.sessionController.updateCurrentStatus(profile)
                if let newPassword = newPasword {
                    self.sessionController.updatePassword(newPassword)
                }
                self.sendUserDidChangeNotification(profile)
            }
        }
    }
    
    private func updateAuth(future: Future<AuthResponse, NSError>) -> Future<AuthResponse, NSError> {
        return future.andThen { result in
            if let response = result.value {
                self.sessionController.setAuth(response)
            }
        }
    }
    
    private func sendUserDidChangeNotification(profile: UserProfile?) {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(UserProfile.CurrentUserDidChangeNotification,
                object: profile, userInfo: nil)
        }
    }
    
    private enum AuthRouter: URLRequestConvertible {
        
        case Login(api: APIService, username: String, password: String)
        case Facebook(api: APIService, fbToken: String)
        case Register(api: APIService, username: String?, password: String?, profileInfo: [String: AnyObject]?)
        case Refresh(api: APIService, token: String)

        // URLRequestConvertible
        var URLRequest: NSURLRequest {
            let url:  NSURL
            var encoding: Alamofire.ParameterEncoding = .JSON
            var method: Alamofire.Method = .POST
            var headers: [String : AnyObject] = [ "Content-Type" : "application/json"]
            var params: [String: AnyObject] = [:]

            switch self {
            case .Refresh(let api, let token):
                url = api.https("/v1.0/users/token")
                method = .GET
                encoding = .URL
                headers = [:]
                params = ["token" : token]
            case .Login(let api, let username, let password):
                url = api.https("/v1.0/users/login")
                params = [
                    "email" : username,
                    "password" : password,
                    "device" : deviceInfo(),
                ]
            case .Facebook(let api, let fbToken):
                url = api.https("/v1.0/users/login")
                params = [
                    "fbToken" : fbToken,
                    "device" : deviceInfo(),
                ]
            case .Register(let api,  let username, let password, let profile):
                url = api.https("/v1.0/users/register")
                method = .POST
                encoding = .JSON
                headers = [ "Content-Type" : "application/json"]
                params = [
                    "device" : deviceInfo(),
                ]
                if let username = username {
                    params["email"] = username
                }
                if let password = password {
                    params["password"] = password
                }
                if let profile = profile {
                    params["profile"] = profile
                }
            }
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            
            return encoding.encode(request, parameters: params).0
        }
        
        private func deviceInfo() -> [String : AnyObject] {
            let device = UIDevice.currentDevice()
            return [
                "make" : device.localizedModel,
                "model" : "\(device.systemName) \(device.systemVersion)",
                "uuid" : device.identifierForVendor.UUIDString,
            ]
        }
    }
    
}


