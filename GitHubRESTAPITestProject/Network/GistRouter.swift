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
    
    case getPublic                                  // GET https://api.github.com/gists/public
    case getAtPath(url: String)                     // GET at given path
    case getMyStarred                               // GET https://api.github.com/gists/starred
    case getMine                                    // GET https://api.github.com/gists
    case isStarred(gistId: String)                  // GET https://api.github.com/gists/\(gistId)/star
    case star(gistId: String)                       // PUT https://api.github.com/gists/\(gistId)/star
    case unstar(gistId: String)                     // DELETE https://api.github.com/gists/\(gistId)/star
    case delete(gistId: String)                     // DELETE https://api.github.com/gists/\(gistId)
    case сreate(parameters: [String: AnyObject])    // POST https://api.github.com/gists
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .getPublic, .getAtPath, .getMyStarred, .getMine, .isStarred:
                return .GET
            case .сreate:
                return .POST
            case .star:
                return .PUT
            case .unstar, .delete:
                return .DELETE
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .getPublic:
                return ("/gists/public", nil)
            case .getAtPath(let path):
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
            case .getMyStarred:
                return ("/gists/starred", nil)
            case .getMine:
                return ("/gists", nil)
            case .isStarred(let id):
                return ("/gists/\(id)/star", nil)
            case .star(let id):
                return ("/gists/\(id)/star", nil)
            case .unstar(let id):
                return ("/gists/\(id)/star", nil)
            case .delete(let id):
                return ("/gists/\(id)", nil)
            case .сreate(let params):
                return ("/gists", params)
            }
        }()
        
        let URL = NSURL(string: GistRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        // Set OAuth token if we have one
        if case .hasToken(token: let token) = OAuth2Manager.sharedInstance.oAuthStatus {
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