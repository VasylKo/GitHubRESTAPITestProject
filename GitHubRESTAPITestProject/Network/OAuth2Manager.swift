//
//  OAuth2Manager.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 31/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class OAuth2Manager{
    static let sharedInstance = OAuth2Manager()

    enum AuthorisationStatus {
        case NotAuthorised
        case Authorising
        case HasToken(token: String)
    }
    
    //MARK: - Private properties
    private let clientID: String = "a3ac089b8988628d38ce"
    private let clientSecret: String = "0da2da635e3de0510ff298d36a7d96e9c8c75cb0"
    
    //MARK: - Internal properties
    private(set) var oAuthStatus: AuthorisationStatus {
        didSet {
            print(oAuthStatus)
        }
    }
    
    //MARK: - Init
    private init() {
        oAuthStatus = .NotAuthorised
    }
    
    //MARK: - Internal methods
    func startAuthorisationProcess() {
        oAuthStatus = .Authorising
    }
    
    func authorisationProcessFail() {
        oAuthStatus = .NotAuthorised
    }
    
    func URLToStartOAuth2Login() -> NSURL? {
        let authPath = "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=gist&state=TEST_STATE"
        guard let authURL:NSURL = NSURL(string: authPath) else {
            return nil
        }
        
        return authURL
    }
    
    func processOAuthResponse(url: NSURL) {        
        //Extract code from response
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if (queryItem.name.lowercaseString == "code") {
                    code = queryItem.value
                    break
                }
            }
        }
        if let receivedCode = code {
            swapAuthCodeForToken(receivedCode)
        } else {
            oAuthStatus = .NotAuthorised
            // TODO: add error here
        }
    }
    
    //MARK: - Private methods
    private func swapAuthCodeForToken(receivedCode: String) {
        let getTokenPath:String = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": clientID, "client_secret": clientSecret, "code": receivedCode]
        let jsonHeader = ["Accept": "application/json"]
        Alamofire.request(.POST, getTokenPath, parameters: tokenParams, headers: jsonHeader)
            .responseString { response in
                guard response.result.error == nil else {
                    self.oAuthStatus = .NotAuthorised
                    // TODO: add error here
                    return
                }
               
                print(response.result.value)
                
                guard let receivedResults = response.result.value, jsonData = receivedResults.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                    self.oAuthStatus = .NotAuthorised
                    // TODO: add error here
                    return
                }
                
                let jsonResults = JSON(data: jsonData)
                
                guard let oAuthToken = jsonResults["access_token"].string else {
                    self.oAuthStatus = .NotAuthorised
                    // TODO: add error here
                    return
                }
                
                self.oAuthStatus = .HasToken(token: oAuthToken)
        }
    }
}