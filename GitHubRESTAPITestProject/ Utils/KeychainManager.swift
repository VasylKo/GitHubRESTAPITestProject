//
//  KeychainManager.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 02/06/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import Locksmith

protocol KeychainManager {
    func saveTokenToKeychain(token: String)
    func loadTokenFromKeychain() -> String?
    func clearKeychain()
}

struct LocksmithKeychainManager: KeychainManager {
    init () {
        prepareKeychain()
    }
    
    func saveTokenToKeychain(token: String) {
        do {
            try Locksmith.updateData(["token": token], forUserAccount: "github")
        } catch {
            clearKeychain()
        }
    }
    
    func loadTokenFromKeychain() -> String? {
        Locksmith.loadDataForUserAccount("github")
        let dictionary = Locksmith.loadDataForUserAccount("github")
        if let token = dictionary?["token"] as? String {
            return token
        } else {
            return nil
        }
    }
    
    func clearKeychain() {
        let _ = try? Locksmith.deleteDataForUserAccount("github")
        print("Keychain cleaned")
    }
    
    // MARK: - Private implementation
    ///Clears Keychain after app reinstall
    private func prepareKeychain() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (!defaults.boolForKey("KeychainUpToDate")) {
            clearKeychain()
            defaults.setBool(true, forKey: "KeychainUpToDate")
        }
        
    }
}