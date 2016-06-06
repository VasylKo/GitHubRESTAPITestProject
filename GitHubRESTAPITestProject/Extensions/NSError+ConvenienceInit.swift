//
//  NSError+ConvenienceInit.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 05.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(domain: String = GitHubAPIManager.ErrorDomain, code: Int = -1, description: String, suggestion: String) {
        let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedRecoverySuggestionErrorKey: suggestion]
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
}