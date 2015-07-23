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

extension APIService {
    
    
    
    func getProfile(token: String, userId: String?, completion: (OperationResult<Bool>)->Void) {
        dataProvider.jsonRequest(ProfileRouter.Get(api: self, token: token, userId: userId), map: emptyResponseMapping(), completion: completion)
    }
    
    
    
    private enum ProfileRouter: URLRequestConvertible {
        case Get(api: APIService, token: String, userId: String?)


        // MARK: URLRequestConvertible
        var URLRequest: NSURLRequest {
            let encoding: Alamofire.ParameterEncoding
            let url:  NSURL
            let headers: [String : AnyObject]
            let params: [String: AnyObject]
            let method: Alamofire.Method = .GET

            switch self {
            case .Get(let api, let token, let userId):
                encoding = .URL
                url = api.http("/v1.0/user")
                params = [:]
                headers = [
                    "Authorization": "Bearer \(token)",
                    "Accept" : "application/json",
                ]
            }
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            
            return encoding.encode(request, parameters: params).0
        }
    }
    
    struct UserProfile: Mappable {
        private(set) var accessToken: String?
        private(set) var refreshToken: String?
        private(set) var expires: Int?
        
        init?(_ map: Map) {
            mapping(map)
            switch (accessToken,refreshToken,expires) {
            case (.Some, .Some, .Some):
                break
            default:
                println("Error while parsing object \(self)")
                return nil
            }
        }
        
        mutating func mapping(map: Map) {
            accessToken <- map["access_token"]
            refreshToken <- map["refresh_token"]
            expires <- map["expires_in"]
        }
        
    }
}


