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

final class GitHubAPIManager {
    static let sharedInstance = GitHubAPIManager()
    
    static let networkIsReachableNotification = "networkIsReachableNotification"
    
    //MARK: - Private properties
    private var alamofireManager: Alamofire.Manager
    private let reachabilityManager: NetworkReachabilityManager?

    private init () {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        alamofireManager = Alamofire.Manager(configuration: configuration)
        
        //Monitor network reachability status
        reachabilityManager = Alamofire.NetworkReachabilityManager()
        reachabilityManager?.listener = { reachabilityStatus in
            if case .Reachable = reachabilityStatus {
                NSNotificationCenter.defaultCenter().postNotificationName(GitHubAPIManager.networkIsReachableNotification, object: self)
            }
            
        }
        reachabilityManager?.startListening()
    }
    
    //MARK: - Intrnal methods for data loading
    //MARK: Data loading
    
    func getPublicGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
        if let urlString = pageToLoad {
            getGists(GistRouter.getAtPath(url: urlString), completionHandler: completionHandler)
        } else {
            getGists(GistRouter.getPublic, completionHandler: completionHandler)
        }
    }
    
    func getMyStarredGists(pageToLoad: String?, completionHandler:(Result<[Gist], NSError>, String?) -> Void) {
        if let urlString = pageToLoad {
            getGists(GistRouter.getAtPath(url: urlString), completionHandler: completionHandler)
        } else {
            getGists(GistRouter.getMyStarred, completionHandler: completionHandler)
        }
    }
    
    func getMyGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
        if let urlString = pageToLoad {
            getGists(GistRouter.getAtPath(url: urlString), completionHandler: completionHandler)
        } else {
            getGists(GistRouter.getMine, completionHandler: completionHandler)
        }
    }
    
    // MARK: Starring / Unstarring / Star status
    func isGistStarred(gistId: String, completionHandler: Result<Bool, NSError> -> Void) {
        // GET /gists/:id/star
        let starStatusRequest = alamofireManager.request(GistRouter.isStarred(gistId: gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                // 204 if starred, 404 if not
                if let error = error {
                    if response?.statusCode == 404 {
                        completionHandler(.Success(false))
                        return
                    }
                    completionHandler(.Failure(error))
                    return
                }
                completionHandler(.Success(true))
        }
        
        debugPrint(starStatusRequest)
    }
    
    func starGist(gistId: String, completionHandler: (NSError?) -> Void) {
        let starRequest = alamofireManager.request(GistRouter.star(gistId: gistId))
            .response { (request, response, data, error) in
                completionHandler(error)
        }
        
        debugPrint(starRequest)
    }
    
    func unstarGist(gistId: String, completionHandler: (NSError?) -> Void) {
        let unstarRequest = alamofireManager.request(GistRouter.unstar(gistId: gistId))
           .response { (request, response, data, error) in
                completionHandler(error)
        }
        
        debugPrint(unstarRequest)
    }
    
    // MARK: Creating and Delete
    func createNewGist(description: String, isPublic: Bool, files: [File], completionHandler: Result<Bool, NSError> -> Void) {
        
        let publicString = isPublic ? "true" : "false"

        var filesDictionary = [String: AnyObject]()
        for file in files {
            guard let name = file.filename, content = file.content else { continue }
            filesDictionary[name] = ["content": content]
        }
    
        let parameters:[String: AnyObject] = [
            "description": description,
            "isPublic": publicString,
            "files" : filesDictionary
        ]
        
        let createNewGistRequest = alamofireManager.request(GistRouter.сreate(parameters: parameters))
            .response { (request, response, data, error) in
                if let error = error {
                    completionHandler(.Failure(error))
                    return
                }
                
                completionHandler(.Success(true))
        }
        
        debugPrint(createNewGistRequest)
    }
    
    func deleteGist(gistId: String, completionHandler: (NSError?) -> Void) {
        let deleteRequest = alamofireManager.request(GistRouter.delete(gistId: gistId))
            .response { (request, response, data, error) in
                completionHandler(error)
        }
        
        debugPrint(deleteRequest)
    }
    
    //MARK: - Loading Images
    func imageFromURLString(imageURLString: String, completionHandler:
        (UIImage?, NSError?) -> Void) {
        alamofireManager.request(.GET, imageURLString)
            .response { (request, response, data, error) in
                // use the generic response serializer that returns NSData
                if data == nil {
                    completionHandler(nil, nil)
                    return
                }
                let image = UIImage(data: data! as NSData)
                completionHandler(image, nil)
        }
    }
    
    //MARK: - Private implementation
    private func getGists(urlRequest: URLRequestConvertible, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
        let gistsRequest = alamofireManager.request(urlRequest)
            .validate()
            .responseArray { (response:Response<[Gist], NSError>) in
                guard response.result.error == nil,
                    let gists = response.result.value else {
                        let error =  self.checkUnauthorized(response.response) ?? response.result.error!
                        completionHandler(.Failure(error), nil)
                        return
                }
                // need to figure out if this is the last page
                // check the link header, if present
                let next = self.getNextPageFromHeaders(response.response)
                completionHandler(.Success(gists), next)
        }
        
        debugPrint(gistsRequest)
    }
    
    //MARK: - Helper
    private func getNextPageFromHeaders(response: NSHTTPURLResponse?) -> String? {
        if let linkHeader = response?.allHeaderFields["Link"] as? String {
            /* looks like:
             <https://api.github.com/user/20267/gists?page=2>; rel="next", <https://api.github.com/user/20267/gists?page=6>; rel="last"
             */
            // so split on "," then on  ";"
            let components = linkHeader.characters.split {$0 == ","}.map { String($0) }
            // now we have 2 lines like
            // '<https://api.github.com/user/20267/gists?page=2>; rel="next"'
            // So let's get the URL out of there:
            for item in components {
                // see if it's "next"
                guard item.rangeOfString("rel=\"next\"", options: []) != nil else { return nil }
                
                let rangeOfPaddedURL = item.rangeOfString("<(.*)>;",
                                                          options: .RegularExpressionSearch)
                
                guard let range = rangeOfPaddedURL else { return nil }
                let nextURL = item.substringWithRange(range)
                // strip off the < and >;
                let startIndex = nextURL.startIndex.advancedBy(1)
                let endIndex = nextURL.endIndex.advancedBy(-2)
                let urlRange = startIndex..<endIndex
                return nextURL.substringWithRange(urlRange)
                
                
            }
        }
        return nil
    }
    
    func checkUnauthorized(urlResponse: NSHTTPURLResponse?) -> (NSError?) {
        guard urlResponse?.statusCode == 401 else { return nil }
        return ErrorGenerator.unauthorizedUserError.generate()
    }
}