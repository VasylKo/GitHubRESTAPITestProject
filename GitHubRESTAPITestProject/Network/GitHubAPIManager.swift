//
//  GitHubAPIManager.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GitHubAPIManager {
    static let sharedInstance = GitHubAPIManager()
    
    func printPublicGists() -> Void {
        Alamofire.request(GistRouter.GetPublic()).responseString { (response: Response<String, NSError>) in
            if let receivedString = response.result.value {
                print(receivedString)
            }
        }
    }
    
        
    func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void) {
        Alamofire.request(.GET, "https://api.github.com/gists/public")
            .responseArray { (response:Response<[Gist], NSError>) in
                completionHandler(response.result)
        }
    }
 
    
}