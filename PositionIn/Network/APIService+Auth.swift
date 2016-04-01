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

extension Future {
    func recoverAuthErrorWith(futureBuilder: Void -> Future<T, E>) -> Future<T, E> {
        return self.recoverWith { error in
            if (error as NSError).code == NSURLErrorNetworkConnectionLost {
                return futureBuilder()
            }
            
            return Future(error: error)
        }
    }
}

extension APIService {
    func handleAuthFailure<R>(fb: Void -> Future<R, NSError>) -> Future<R, NSError> {
        return fb().recoverAuthErrorWith(fb).recoverAuthErrorWith(fb).recoverAuthErrorWith(fb).onFailure { error in
            if let e = NetworkDataProvider.ErrorCodes.fromError(error) where e == .SessionRevokedError {
                self.logout()
            }
            self.defaultErrorHandler?(error)
        }
    }
    
    //Returns current user id
    func currentUserId() -> CRUDObjectId? {
        return sessionController.currentUserId()
    }
    
    //Returns current user id
    func currentUserId() -> Future<CRUDObjectId, NSError> {
        return sessionController.currentUserId()
    }
    
    func isUserHasActiveMembershipPlan() -> Bool {
        return sessionController.isUserHasActiveMembershipPlan()
    }
    
    //Returns true if user is registered
    func isUserAuthorized() -> Bool {
        return sessionController.isUserAuthorized()
    }
    
    //Success if user is registered
    func isUserAuthorized() -> Future<Void, NSError> {
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            return self.sessionController.isUserAuthorized()
        }
        return handleAuthFailure(futureBuilder)
    }
    
    
    //Returns true if it is current user
    func isCurrentUser(userId: CRUDObjectId) -> Bool {
        if let currentUserId: CRUDObjectId = api().currentUserId() {
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
                let userPassword = apiService.sessionController.currentAccessToken()
                switch (userId, userPassword) {
                case (let user?, let password?):
                    let hostname = AppConfiguration().xmppHostname
                    let jid = "\(user)@\(hostname)"
                    return XMPPCredentials(jid: jid, password: password)
                case (_, nil):
                    // refresh token
                    api().session().onSuccess(callback: { token in
                        Log.debug?.message("new token for chat: \(token)")
                    })
                    return nil
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
        return session().flatMap { _ in
            return self.sessionController.isUserAuthorized()
        }.flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    // Success on existing session or after token refresh
    func session() -> Future<AuthResponse.Token, NSError> {
        return sessionController.session().recoverWith { _ in
            return self.refreshToken().map { response in
                return response.accessToken
                }.onFailure { error in
                    trackGoogleAnalyticsEvent("Token", action: "RefreshFailed", label: error.localizedDescription)
            }
        }
    }
    
    // Logout from the current session
    func logout() -> Future<Void, BrightFutures.NoError> {
        return sessionController.logout().onComplete { _ in
            self.sendUserDidChangeNotification(nil)
        }
    }
    
    
    // Logout from server to stop receiving push notifications and then expire current session
    func logoutFromServer() -> Future<Void, NSError> {
        return session().flatMap{ [unowned self] accessToken in
            return self.logoutRequest(accessToken: accessToken)
            }.onSuccess { [unowned self] _ in
                self.logout()
            }
    }
    
    //Verify Phone
    //0 - api type for sms validation
    //1 - api type for sms validation (duplicate functionality)
    //2 - api type for phone validation call call
    func verifyPhone(phoneNumber: String, type: NSNumber) -> Future<Void, NSError> {
        return verifyPhoneRequest(phoneNumber, type: type)
    }
    
    //Validate Code
    func verifyPhoneCode(phoneNumber: String, code: String) -> Future<Bool, NSError> {
        return verifyPhoneCodeRequest(phoneNumber, code: code)
    }
    
    //Login existing user
    func login(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?) -> Future<UserProfile, NSError> {
        return loginRequest(username: username, password: password, phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode).flatMap { _ in
            return self.updateCurrentProfileStatus(password)
        }
    }

    //Login via fb
    func login(fbToken: String) -> Future<UserProfile, NSError> {
        return facebookLoginRequest(fbToken).flatMap { _ in
            //TODO: need add saving userName to keychain
            return self.updateCurrentProfileStatus()
        }
    }
    
    //Register anonymous user
    func register() -> Future<UserProfile, NSError> {
        return registerRequest(nil, username: nil, password: nil, phoneNumber: nil, phoneVerificationCode: nil, info: nil).flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    //Register new user
    func register(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, firstName: String?, lastName: String?, email: String?) -> Future<UserProfile, NSError> {
        var info: [String: AnyObject] = [:]
        if let firstName = firstName {
            info ["firstName"] = firstName
        }
        if let lastName = lastName {
            info ["lastName"] = lastName
        }
        return registerRequest(email, username: username, password: password, phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode, info: info).flatMap { _ in
            return self.updateCurrentProfileStatus(password)
        }
    }
    
    //MARK: - Private members -
    
    private func registerRequest(email: String?, username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, info: [String: AnyObject]?) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Register(api: self, email:email, username: username, password: password, phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode, profileInfo: info)
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let futureBuilder: (Void -> Future<AuthResponse, NSError>) = { [unowned self] in
            let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
            let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = self.dataProvider.request(urlRequest, serializer: serializer, validation: nil)
            return self.updateAuth(future)
        }
            
        return handleAuthFailure(futureBuilder)
    }
    
    private func verifyPhoneRequest(phoneNumber: String, type: NSNumber) ->  Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            let request = AuthRouter.PhoneVerification(api: self, phone: phoneNumber, type: type)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: nil)
            return future
        }
        
        return self.handleAuthFailure(futureBuilder)
    }
    
    private func verifyPhoneCodeRequest(phoneNumber: String, code: String) ->  Future<Bool, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Bool, NSError>)
        
        let futureBuilder: (Void -> Future<Bool, NSError>) = { [unowned self] in
            let request = AuthRouter.VerifyPhoneCode(api: self, phone: phoneNumber, code: code)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.phoneCodeMapping(), validation: nil)
            return future
        }
            
        return self.handleAuthFailure(futureBuilder)
    }
    
    private func loginRequest(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?)
        -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Login(api: self, username: username, password: password,
            phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode)
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let futureBuilder: (Void -> Future<AuthResponse, NSError>) = { [unowned self] in
            let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
            let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = self.dataProvider.request(urlRequest, serializer: serializer, validation: nil)
            return self.updateAuth(future)
        }
        
        return handleAuthFailure(futureBuilder)
    }
    
    private func logoutRequest(accessToken accessToken: String) -> Future<Void, NSError> {
        
        typealias ResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            let request = AuthRouter.Logout(api: self, accessToken: accessToken)
            let serializer = Alamofire.Request.LogoutEmptyResponseSerializer()
            let (_, future): ResultType = self.dataProvider.request(request, serializer: serializer, validation: nil)
            return future
        }

        return handleAuthFailure(futureBuilder)
    }
    
    private func facebookLoginRequest(fbToken: String) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Facebook(api: self, fbToken: fbToken)
        
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let futureBuilder: (Void -> Future<AuthResponse, NSError>) = { [unowned self] in
            let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
            let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = self.dataProvider.request(urlRequest, serializer: serializer, validation: nil)
            return self.updateAuth(future)
        }
    
        return handleAuthFailure(futureBuilder)
    }
    
    private func refreshToken() -> Future<AccessTokenResponse, NSError> {
        return sessionController.currentRefreshToken().flatMap { (token: AccessTokenResponse.Token) ->
            Future<AccessTokenResponse, NSError> in
            let urlRequest = AuthRouter.Refresh(api: self, token: token)
            
            let mapping: AnyObject? -> AccessTokenResponse? = { json in
                return Mapper<AccessTokenResponse>().map(json)
            }
            
            let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
            let (_, future): (Alamofire.Request, Future<AccessTokenResponse, NSError>) = self.dataProvider.request(urlRequest, serializer: serializer, validation: nil)
            
            return self.updateAccessToken(future)
        }
    }
//TODO: should be private
    func updateCurrentProfileStatus(newPasword: String? = nil) -> Future<UserProfile, NSError> {
        return getMyProfile().andThen { result in
            if let profile = result.value {
                self.sessionController.updateCurrentStatus(profile)                
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
    
    private func updateAccessToken(future: Future<AccessTokenResponse, NSError>)
        -> Future<AccessTokenResponse, NSError> {
        return future.andThen { result in
            if let response = result.value {
                self.sessionController.setAccessTokenResponse(response)
            }
        }
    }
    
    private func sendUserDidChangeNotification(profile: UserProfile?) {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(UserProfile.CurrentUserDidChangeNotification,
                object: profile, userInfo: nil)
        }
    }
    
    func phoneCodeMapping() -> (AnyObject? -> Bool?) {
        return { response in
            if let json = response as? NSDictionary {
                if let isExistingUser = json["isExistingUser"] as? Bool{
                    return isExistingUser
                } else {
                    Log.error?.message("Got unexpected response")
                    Log.debug?.value(json)
                    return nil
                }
            }
            else {
                Log.error?.message("Got unexpected response: \(response)")
                return nil
            }
        }
    }
    
    private enum AuthRouter: URLRequestConvertible {
        
        case Login(api: APIService, username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?)
        case Logout(api: APIService, accessToken: String)
        case Facebook(api: APIService, fbToken: String)
        case Register(api: APIService, email: String?, username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, profileInfo: [String: AnyObject]?)
        case Refresh(api: APIService, token: String)
        case PhoneVerification(api: APIService, phone: String, type: NSNumber)
        case VerifyPhoneCode(api: APIService, phone: String, code: String)
        
        // URLRequestConvertible
        var URLRequest: NSMutableURLRequest {
            let url:  NSURL
            var encoding: Alamofire.ParameterEncoding = .JSON
            var method: Alamofire.Method = .POST
            var headers: [String : String] = [ "Content-Type" : "application/json"]
            var params: [String: AnyObject] = [:]

            switch self {
            case .VerifyPhoneCode(let api, let phone, let code):
                url = api.https("/v1.0/users/verifyPhoneVerificationCode")
                params = [
                    "phoneNumber" : phone,
                    "phoneVerificationCode" : code,
                    "device" : deviceInfo(),
                ]
            case .PhoneVerification(let api, let phone, let type):
                url = api.https("/v1.0/users/phoneVerification")
                params = [
                    "phoneNumber" : phone,
                    "type" : type,
                    "device" : deviceInfo()
                ]
            case .Refresh(let api, let token):
                url = api.https("/v1.0/users/token")
                method = .GET
                encoding = .URL
                let cookie: NSHTTPCookie? = NSHTTPCookie(properties:[NSHTTPCookieName: "refresh_token",
                    NSHTTPCookieValue: token, NSHTTPCookiePath: "/", NSHTTPCookieOriginURL: url])
                
                if let cookie = cookie {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                }
                
            case .Login(let api, let username, let password, let phoneNumber, let phoneVerificationCode):
                url = api.https("/v1.0/users/login")
                params = [
                    "device" : deviceInfo(),
                ]
                if let username = username {
                    params["email"] = username
                }
                if let password = password {
                    params["password"] = password
                }
                if let phoneNumber = phoneNumber {
                    params["phoneNumber"] = phoneNumber
                }
                if let phoneVerificationCode = phoneVerificationCode {
                    params["phoneVerificationCode"] = phoneVerificationCode
                }
            case .Logout(let api, let accessToken):
                url = api.https("/v1.0/users/logout")
                method = .GET
                encoding = .URL
                
                //Add headers needed for logout
                headers = [:]
                headers["Accept"] = "application/json"
                headers["Authorization"] = "Bearer \(accessToken)"

            case .Facebook(let api, let fbToken):
                url = api.https("/v1.0/users/login")
                params = [
                    "fbToken" : fbToken,
                    "device" : deviceInfo(),
                ]
            case .Register(let api, let email, let username, let password, let phoneNumber, let phoneVerificationCode, let profile):
                url = api.https("/v1.0/users/register")
                method = .POST
                encoding = .JSON
                headers = [ "Content-Type" : "application/json"]
                params = [
                    "device" : deviceInfo(),
                ]
                if let email = email {
                    params["email"] = email
                }
                if let username = username {
                    params["email"] = username
                }
                if let password = password {
                    params["password"] = password
                }
                if let phoneNumber = phoneNumber {
                    params["phoneNumber"] = phoneNumber
                }
                if let phoneVerificationCode = phoneVerificationCode {
                    params["phoneVerificationCode"] = phoneVerificationCode
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
            var info = [
                "make" : device.localizedModel,
                "model" : "\(device.systemName) \(device.systemVersion)",
                "os" : "IOS"
            ];
            if let uuid = device.identifierForVendor {
                info["uuid"] = uuid.UUIDString
            }
            return info
        }
    }
}


private extension Alamofire.Request {
    
    //MARK: - Custom serializer -
    private static func AuthResponseSerializer<T>(mapping: AnyObject? -> T?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            if let statusCode = response?.statusCode where statusCode == 400 || statusCode == 401 {
                var attributes = [String: String]()
                NewRelicController.logWithUser("Refresh token error \(statusCode)", attributes: attributes)
                
                return .Failure(NetworkDataProvider.ErrorCodes.SessionRevokedError.error())
            }
            
            // Cookies parsing
            var refreshTokenCookie: NSHTTPCookie? = nil
            if let response = response,
                let allFields = response.allHeaderFields as? [String : String] {
                    var responseURL: NSURL = NSURL(string: "")!
                    if let url: NSURL = response.URL {
                        responseURL = url
                    }
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(allFields, forURL:responseURL)
                    func getRefreshTokenCookie(cookies: [NSHTTPCookie]) -> [NSHTTPCookie] {
                        return cookies.filter{$0.name == "refresh_token"}
                    }
                    refreshTokenCookie = getRefreshTokenCookie(cookies).first
            }
            
            // Response body parsing
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let json):
                let mutableJSON = json.mutableCopy() as? NSMutableDictionary
                if let rtc = refreshTokenCookie where mutableJSON != nil {
                    mutableJSON!["refresh_token"] = rtc.value
                    mutableJSON!["refresh_token_expires_in"] = rtc.expiresDate?.timeIntervalSinceDate(NSDate())
                }
                guard let object = mapping(mutableJSON) else {
                    if  let jsonDict = json as? [String: AnyObject],
                        let msg = jsonDict["error"] as? String {
                            return .Failure(NetworkDataProvider.ErrorCodes.TransferError.error(localizedDescription: msg))
                    }
                    return .Failure(NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
                }
                return .Success(object)
            case .Failure(let error):
                return .Failure(NetworkDataProvider.ErrorCodes.ParsingError.error(error))
            }
        }
    }
    
    //MARK: - Custom serializer -
    private static func LogoutEmptyResponseSerializer() -> ResponseSerializer<Void, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            if let statusCode = response?.statusCode where statusCode == 200 {
                return .Success()
            } else {
                return .Failure(NetworkDataProvider.ErrorCodes.InvalidSessionError.error())
            }
            
        }
    }

}