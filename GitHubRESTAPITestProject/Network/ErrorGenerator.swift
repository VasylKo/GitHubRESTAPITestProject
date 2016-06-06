//
//  ErrorGenerator.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 05.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation


enum ErrorGenerator {
    case oAuthCodeError(description: String?, suggestion: String?)
    case oAuthTokenError(description: String?, suggestion: String?)
    case customeError(domain: String?, code: Int?, description: String, suggestion: String)
    
    static let ErrorDomain = "com.error.GitHubAPIManager"
    
    func generate() -> NSError {
        switch self {
        case let .oAuthCodeError(description, suggestion):
            return
        default:
            <#code#>
        }
    }
}