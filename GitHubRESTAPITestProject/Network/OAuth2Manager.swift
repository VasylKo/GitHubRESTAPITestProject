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

protocol OAuth2ManagerDelegate: class {
    func authorisationStatusDidChanged(authorisationStatus: OAuth2Manager.AuthorisationStatus)
}

final class OAuth2Manager{
    static let sharedInstance = OAuth2Manager()

    enum AuthorisationStatus: CustomStringConvertible {
        case NotAuthorised(error: NSError?)
        case Authorising
        case HasToken(token: String)
        
        var description: String {
            switch self {
            case .NotAuthorised:
                return "NotAuthorised"
            case .Authorising:
                return "Authorising"
            case .HasToken:
                return "HasToken"
            }
        }
    }
    
    //MARK: - Private properties
    private let clientID: String = "a3ac089b8988628d38ce"
    private let clientSecret: String = "0da2da635e3de0510ff298d36a7d96e9c8c75cb0"
    private let keychainManager: KeychainManager
    
    //MARK: - Internal properties
    weak var delegate: OAuth2ManagerDelegate?
    private(set) var oAuthStatus: AuthorisationStatus {
        didSet {
            print("Authorisation (OAuth2) Status Changed to : \(oAuthStatus)")
            if case let .NotAuthorised(error: error?) = oAuthStatus {
                print("ERROR: \(error.localizedDescription)")
            }
            delegate?.authorisationStatusDidChanged(oAuthStatus)
        }
    }
    
    //MARK: - Init
    private init() {
        keychainManager = LocksmithKeychainManager()
        
        //Try to load token from Keychain
        if let token = keychainManager.loadTokenFromKeychain() {
            oAuthStatus = .HasToken(token: token)
        } else {
            oAuthStatus = .NotAuthorised(error: nil)
        }
    }
    
    //MARK: - Internal methods
    func startAuthorisationProcess() {
        oAuthStatus = .Authorising
    }
    
    func authorisationProcessFail(withError error: NSError? = nil) {
        oAuthStatus = .NotAuthorised(error: error)
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
        
        guard let queryItems = components?.queryItems else {
            authorisationProcessFail(withError: ErrorGenerator.oAuthCodeError.generate())
            return
        }
        for queryItem in queryItems {
            guard queryItem.name.lowercaseString == "code" else { continue }
            code = queryItem.value
        }
        
        guard let receivedCode = code else {
            authorisationProcessFail(withError: ErrorGenerator.oAuthCodeError.generate())
            return
        }
        
        swapAuthCodeForToken(receivedCode)
        
    }
    
    //MARK: - Private methods
    private func swapAuthCodeForToken(receivedCode: String) {
        let getTokenPath:String = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": clientID, "client_secret": clientSecret, "code": receivedCode]
        let jsonHeader = ["Accept": "application/json"]
        let authTokenRequest = Alamofire.request(.POST, getTokenPath, parameters: tokenParams, headers: jsonHeader)
            .responseString { [weak self] response in
                guard let strongSelf = self else { return }
                
                guard response.result.error == nil else {
                    strongSelf.authorisationProcessFail(withError: response.result.error)
                    return
                }
            
                guard let receivedResults = response.result.value, jsonData = receivedResults.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                    strongSelf.authorisationProcessFail(withError: ErrorGenerator.oAuthTokenError.generate(customDescription: "Could not parse an OAuth token"))
                    return
                }
                
                let jsonResults = JSON(data: jsonData)
                
                guard let oAuthToken = jsonResults["access_token"].string else {
                    strongSelf.authorisationProcessFail(withError: ErrorGenerator.oAuthTokenError.generate(customDescription: "Response don't contain an OAuth token"))
                    return
                }
                
                strongSelf.keychainManager.saveTokenToKeychain(oAuthToken)
                strongSelf.oAuthStatus = .HasToken(token: oAuthToken)
        }
        
        debugPrint(authTokenRequest)
    }
}