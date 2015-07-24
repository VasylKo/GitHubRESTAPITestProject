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

extension APIService {
        
    func logout() -> Future<Void, NoError> {
        return future {
            self.sessionController.setAuth(AuthResponse.invalidAuth())
        }
    }
    
    func auth(#username: String, password: String) -> Future<AuthResponse, NSError> {
        let (_, future): (Alamofire.Request, Future<AuthResponse, NSError>) = dataProvider.objectRequest(AuthRouter.Auth(api: self, username: username, password: password))
        future.andThen { result in
            if let response = result.value {
                self.sessionController.setAuth(response)
            }
        }
        return future
    }
    
    func createProfile(#username: String, password: String) -> Future<Void, NSError> {
        let (request, future): (Alamofire.Request, Future<Void, NSError>) = dataProvider.jsonRequest(AuthRouter.Register(api: self, username: username, password: password), map: emptyResponseMapping())
        request.validate(statusCode: [201])
        return future    
    }
    
    
    private enum AuthRouter: URLRequestConvertible {
        case Auth(api: APIService, username: String, password: String)
        case Register(api: APIService, username: String, password: String)

        // MARK: URLRequestConvertible
        var URLRequest: NSURLRequest {
            let encoding: Alamofire.ParameterEncoding
            let url:  NSURL
            let headers: [String : AnyObject]
            let params: [String: AnyObject]
            let method: Alamofire.Method = .POST

            switch self {
            case .Auth(let api, let username, let password):
                encoding = .URL
                url = api.http("/oauth/token")
                params = [
                    "scope" : "read write",
                    "grant_type" : "password",
                    "username" : username,
                    "password" : password,
                ]
                let clientId = "11111111111111111111111111111111"
                let clientSecret = "22222222222222222222222222222222"
                let credentialData = "\(clientId):\(clientSecret)".dataUsingEncoding(NSUTF8StringEncoding)!
                let base64Credentials = credentialData.base64EncodedStringWithOptions(nil)
                headers = [
                    "Authorization": "Basic \(base64Credentials)",
                    "Accept" : "application/json",
                ]
            case .Register(let api, let username, let password):
                encoding = .JSON
                url = api.http("/v1.0/user")
                headers = [:]
                params = [
                    "email" : username,
                    "password" : password,
                ]                
            }
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            
            return encoding.encode(request, parameters: params).0
        }
    }
    
    struct AuthResponse: Mappable, DebugPrintable {
        typealias Token = String!
        private(set) var accessToken: Token
        private(set) var refreshToken: Token
        private(set) var expires: Int!
        
        init?(_ map: Map) {
            mapping(map)
            switch (accessToken,refreshToken,expires) {
            case (.Some, .Some, .Some):
                break
            default:
                Log.error?.message("Error while parsing object")
                Log.debug?.trace()
                Log.verbose?.value(self)
                return nil
            }
        }
        
        private init(accessToken: Token, refreshToken: Token, expires: Int) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expires = expires
        }
        
        mutating func mapping(map: Map) {
            accessToken <- map["access_token"]
            refreshToken <- map["refresh_token"]
            expires <- map["expires_in"]
        }
        
        var debugDescription: String {
            return "Access:\(accessToken), Refresh: \(refreshToken), Expires: \(expires)"
        }
        
        static func invalidAuth() -> AuthResponse {
            return  AuthResponse(accessToken: "",refreshToken: "",expires: -1)
        }
    }
}


