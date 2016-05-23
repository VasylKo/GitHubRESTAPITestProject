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
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .GetPublic:
                return .GET
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .GetPublic:
                return ("/gists/public", nil)
            }
        }()
        
        let URL = NSURL(string: GistRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encoded, _) = encoding.encode(URLRequest, parameters: result.parameters)
        encoded.HTTPMethod = method.rawValue
        
        return encoded
    }
}