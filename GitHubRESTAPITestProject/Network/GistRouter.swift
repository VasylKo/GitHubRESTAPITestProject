    //
//  GistRouter.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.


//  Responsible for creating the URL requests and stop our API manager from getting unweildy.

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {
    static let baseURLString:String = "https://api.github.com"
    
    case GetPublic() // GET https://api.github.com/gists/public
    case GetAtPath(String) // GET at given path
    case GetMyStarred() // GET https://api.github.com/gists/starred
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .GetPublic:
                return .GET
            case .GetAtPath:
                return .GET
            case .GetMyStarred:
                return .GET
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .GetPublic:
                return ("/gists/public", nil)
            case .GetAtPath(let path):
                let URL = NSURL(string: path)
                let relativePath = URL!.relativePath!
                var parameters = [String: AnyObject]()
                if let query = URL!.query {
                    let components = query.characters.split {$0 == "="}.map{ String($0) }
                    if components.count >= 2 {
                        parameters[components[0]] = components[1]
                    }
                }
                return (relativePath, parameters)
            case .GetMyStarred:
                return ("/gists/starred", nil)
            }
        }()
        
        let URL = NSURL(string: GistRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        // Set OAuth token if we have one
        if case .HasToken(token: let token) = OAuth2Manager.sharedInstance.oAuthStatus {
            URLRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var encoding: Alamofire.ParameterEncoding {
            switch method {
            case .GET:
                return .URL
            default:
                return .JSON
            }
        }
        
        let (encoded, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encoded.HTTPMethod = method.rawValue
        
        return encoded
    }
}