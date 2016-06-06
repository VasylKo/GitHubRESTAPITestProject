//
//  ErrorGenerator.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 05.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation


enum ErrorGenerator {
    case noInternetConnectionError
    case oAuthAuthorizationURLError
    case oAuthCodeError
    case oAuthTokenError
    case customError
    
    static let ErrorApiDomain = "com.error.GitHubAPIManager"
    
    //MARK: - Error creation
    func generate(customDomain domain: String? = nil, customCode code: Int? = nil, customDescription description: String? = nil, customSuggestion suggestion: String? = nil) -> NSError {
            return NSError(domain: domain ?? defaultErrorDomain(), code: code ?? defaultErrorCode(), description: description ?? defaultErrorDescription() , suggestion: suggestion ??  defaultErrorSuggestion())
    }
    
    
    //MARK: - Helper private methods
    private func defaultErrorDomain() -> String {
        switch self {
        default:
            return ErrorGenerator.ErrorApiDomain
        }
    }
    
    private func defaultErrorCode() -> Int {
        switch self {
        case .noInternetConnectionError:
            return NSURLErrorNotConnectedToInternet
        default:
            return -1
        }
    }
    
    private func defaultErrorDescription() -> String {
        switch self {
        case .noInternetConnectionError:
            return "No Internet Connection"
        case .oAuthAuthorizationURLError:
            return "Could not create an OAuth authorization URL"
        case .oAuthCodeError:
            return "Could not obtain an OAuth code"
        case .oAuthTokenError:
            return "Could not obtain an OAuth token"
        default:
            return "Unknown error occurred"
        }
    }
    
    private func defaultErrorSuggestion() -> String {
        switch self {
        case .noInternetConnectionError, .oAuthAuthorizationURLError, .oAuthCodeError, .oAuthTokenError:
            return "Please retry your request"
        default:
            return "Something went wrong. Our team is working on that."
        }
    }
}