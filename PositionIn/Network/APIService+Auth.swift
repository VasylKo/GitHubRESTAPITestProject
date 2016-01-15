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
    
    //Verify Phone
    func verifyPhone(phoneNumber: String) -> Future<Void, NSError> {
        return verifyPhoneRequest(phoneNumber)
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
        return registerRequest(username: nil, password: nil, phoneNumber: nil, phoneVerificationCode: nil, info: nil).flatMap { _ in
            return self.updateCurrentProfileStatus()
        }
    }
    
    //Register new user
    func register(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, firstName: String?, lastName: String?) -> Future<UserProfile, NSError> {
        var info: [String: AnyObject] = [:]
        if let firstName = firstName {
            info ["firstName"] = firstName
        }
        if let lastName = lastName {
            info ["lastName"] = lastName
        }
        return registerRequest(username: username, password: password, phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode, info: info).flatMap { _ in
            return self.updateCurrentProfileStatus(password)
        }
    }
    
    //MARK: - Private members -
    
    private func registerRequest(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, info: [String: AnyObject]?) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Register(api: self, username: username, password: password, phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode, profileInfo: info)
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.request(urlRequest, serializer: serializer, validation: nil)
        
        return handleFailure(updateAuth(future))
    }
    
    private func verifyPhoneRequest(phoneNumber: String) ->  Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        let request = AuthRouter.PhoneVerification(api: self, phone: phoneNumber)
        let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: self.statusCodeValidation(statusCode: [200]))
        return self.handleFailure(future)
    }
    
    private func verifyPhoneCodeRequest(phoneNumber: String, code: String) ->  Future<Bool, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Bool, NSError>)
        let request = AuthRouter.VerifyPhoneCode(api: self, phone: phoneNumber, code: code)
        
        let serializer = Alamofire.Request.validationCodeResponseSerializer(self.phoneCodeValidation())
        let (_, future): (Alamofire.Request, Future<Bool, NSError>) = dataProvider.request(request,
            serializer: serializer,
            validation: nil)
        return self.handleFailure(future)
    }
    
    private func loginRequest(username username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?)
        -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Login(api: self, username: username, password: password,
            phoneNumber: phoneNumber, phoneVerificationCode: phoneVerificationCode)
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.request(urlRequest, serializer: serializer, validation: nil)
        return handleFailure(updateAuth(future))
    }
    
    private func facebookLoginRequest(fbToken: String) -> Future<AuthResponse, NSError> {
        let urlRequest = AuthRouter.Facebook(api: self, fbToken: fbToken)
        
        
        let mapping: AnyObject? -> AuthResponse? = { json in
            return Mapper<AuthResponse>().map(json)
        }
        
        let serializer = Alamofire.Request.AuthResponseSerializer(mapping)
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.request(urlRequest, serializer: serializer, validation: nil)
        
    
        return handleFailure(updateAuth(future))
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
    
    private enum AuthRouter: URLRequestConvertible {
        
        case Login(api: APIService, username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?)
        case Facebook(api: APIService, fbToken: String)
        case Register(api: APIService, username: String?, password: String?, phoneNumber: String?, phoneVerificationCode: String?, profileInfo: [String: AnyObject]?)
        case Refresh(api: APIService, token: String)
        case PhoneVerification(api: APIService, phone: String)
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
            case .PhoneVerification(let api, let phone):
                url = api.https("/v1.0/users/phoneVerification")
                params = [
                    "phoneNumber" : phone,
                    "device" : deviceInfo(),
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
            case .Facebook(let api, let fbToken):
                url = api.https("/v1.0/users/login")
                params = [
                    "fbToken" : fbToken,
                    "device" : deviceInfo(),
                ]
            case .Register(let api,  let username, let password, let phoneNumber, let phoneVerificationCode, let profile):
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
    private static func validationCodeResponseSerializer<T>(mapping: AnyObject? -> T?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let json):
                guard let object = mapping(json) else {
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
    private static func AuthResponseSerializer<T>(mapping: AnyObject? -> T?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            if let statusCode = response?.statusCode where statusCode == 401 {
                return .Failure(NetworkDataProvider.ErrorCodes.InvalidSessionError.error())
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
            var json: NSDictionary?
            guard let validData = data where validData.length > 0 else {
                let failureReason = "JSON could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(validData, options:  .AllowFragments) as? NSDictionary
                json = JSON
            } catch {
                return .Failure(error as NSError)
            }
            
            //Response body and refresh token association
            var result: NSDictionary? = json
            if let json = json, let rtc = refreshTokenCookie {
                let mutableJSON = NSMutableDictionary(dictionary: json)
                mutableJSON["refresh_token"] = rtc.value
                mutableJSON["refresh_token_expires_in"] = rtc.expiresDate?.timeIntervalSinceDate(NSDate())
                
                result = mutableJSON
            }

            //Mapping reponse
            guard let object = mapping(result) else {
                if  let jsonDict = json as? [String: AnyObject],
                    let msg = jsonDict["error"] as? String {
                        return .Failure(NetworkDataProvider.ErrorCodes.TransferError.error(localizedDescription: msg))
                }
                return .Failure(NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
            }
            return .Success(object)
        }
    }
}