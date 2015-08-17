//
//  APIService.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import Alamofire
import ObjectMapper
import BrightFutures
import CleanroomLogger

struct APIService {
    
    func getMyProfile() -> Future<UserProfile, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<UserProfile,NSError> in
            let request = self.readRequest(token, endpoint: UserProfile.myProfileEndpoint())
            let (_ , future): (Alamofire.Request, Future<UserProfile,NSError>) = self.dataProvider.objectRequest(request)
            return future.andThen { result in
                if let profile = result.value {
                    NSNotificationCenter.defaultCenter().postNotificationName(UserProfile.CurrentUserDidChangeNotification,
                        object: profile, userInfo: nil)
                }
            }
            
        }
    }
    
    func updateMyProfile(object: UserProfile) -> Future<Void,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Void,NSError> in
            let urlRequest = self.updateRequest(token, endpoint: UserProfile.myProfileEndpoint(), method: .PUT, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<Void, NSError>) = self.dataProvider.jsonRequest(urlRequest, map: self.emptyResponseMapping(), validation: self.statusCodeValidation(statusCode: [204]))
            return future
            
        }
    }
    
    
    func getUserPosts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Post>,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<Post>, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            let params = page.query
            let request = self.readRequest(token, endpoint: endpoint, params: params)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<Post>, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    func createUserPost(userId: CRUDObjectId, post object: Post) -> Future<Post, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Post, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            let params = Mapper().toJSON(object)
            let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
            let (_ , future): (Alamofire.Request, Future<UpdateResponse, NSError>) = self.dataProvider.objectRequest(request)
            return future.map { (updateResponse: UpdateResponse) -> Post in
                var updatedObject = object
                updatedObject.objectId = updateResponse.objectId
                return updatedObject
            }
        }
    }
    
    func getFeed(params: APIServiceQueryConvertible) -> Future<CollectionResponse<FeedItem>,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<FeedItem>, NSError> in
            let request = self.readRequest(token, endpoint: FeedItem.endpoint(), params: params.query)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<FeedItem>, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    func uploadImage(data: NSData) -> Future<NSURL, NSError> {
        
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<AnyObject?,NSError> in
            let urlRequest = self.imageRequest(token)
            return self.dataProvider.upload(urlRequest, content: ["file" : data])
        }.flatMap { (response: AnyObject?) -> Future<NSURL, NSError> in
            let p = Promise<NSURL, NSError>()
            if  let JSON = response as? [String: AnyObject],
                let urlString = JSON["uri"] as? String {
                 let url = self.amazonURL.URLByAppendingPathComponent(urlString)
                 p.success(url)
            } else {
                 p.failure(NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
            }
            return p.future
        }
    }
    
    
    //TODO: check usage
    func getAll<C: CRUDObject>(endpoint: String) -> Future<CollectionResponse<C>, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<C>,NSError> in
            let request = self.readRequest(token, endpoint: endpoint)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<C>, NSError>) = self.dataProvider.objectRequest(request)
            return future
            
        }
    }
    
    //TODO: check usage
    func get<C: CRUDObject>(objectID: CRUDObjectId) -> Future<C, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let request = self.readRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(objectID))
            let (_ , future): (Alamofire.Request, Future<C, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    //TODO: check usage
    func update<C: CRUDObject>(object: C) -> Future<Void,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Void,NSError> in
            
            let urlRequest = self.updateRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(object.objectId), method: .PUT, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<Void, NSError>) = self.dataProvider.jsonRequest(urlRequest, map: self.emptyResponseMapping(), validation: self.statusCodeValidation(statusCode: [204]))
            return future
        }
    }

    //TODO: check usage
    func post<C: CRUDObject>(object: C) -> Future<C,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C,NSError> in
            let urlRequest = self.updateRequest(token, endpoint: C.endpoint(), method: .POST, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<C, NSError>) = self.dataProvider.objectRequest(urlRequest, validation: self.statusCodeValidation(statusCode: [201]))
            return future
        }
    }
    
    
    var description: String {
        return "API: \(baseURL.absoluteString)"
    }
    
    init (url: NSURL, amazon: NSURL, dataProvider: NetworkDataProvider = NetworkDataProvider()) {
        baseURL = url
        amazonURL = amazon
        self.dataProvider = dataProvider
        sessionController = SessionController()
    }
    
//    @availability(*, unavailable)
    func emptyResponseMapping() -> (AnyObject? -> Void?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let errorMessage = json["message"] as? String {
                    Log.error?.message("Server Error: \(errorMessage)")
                } else {
                    Log.error?.message("Got unexpected answer")
                    Log.debug?.value(json)
                }
                return nil
            }
            return ()
        }
    }
    
    func statusCodeValidation<S: SequenceType where S.Generator.Element == Int>(statusCode acceptableStatusCode: S) -> Alamofire.Request.Validation {
        return { _, response in
            return contains(acceptableStatusCode, response.statusCode)
        }
    }
    
    
    //TODO: make private, move to request
    internal func http(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "http")
    }
    //TODO: make private, move to request
    internal func https(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "https")
    }

    private func url(endpoint: String, scheme: String, port: Int? = nil) -> NSURL {
        if let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) {
            components.scheme = scheme
            components.path = (components.path ?? "").stringByAppendingPathComponent(endpoint)
            if let port = port {
                components.port = port
            }
            if let url = components.URL {
                return url
            }
        }
        fatalError("Could not generate  url")
    }
    
    private let baseURL: NSURL
    private let amazonURL: NSURL
//TODO: make private
    internal let dataProvider: NetworkDataProvider
    internal let sessionController: SessionController

    
    private func readRequest(token: String, endpoint: String, params: [String : AnyObject]? = nil) -> CRUDRequest {
        var request = CRUDRequest(token: token, url: https(endpoint))
        request.params = params
        return request
    }

    private func updateRequest(token: String, endpoint: String, method: Alamofire.Method = .POST, params: [String : AnyObject]? = nil) -> CRUDRequest {
        var request = CRUDRequest(token: token, url: https(endpoint))
        request.encoding = .JSON
        request.method = method
        request.params = params
        return request
    }
    
    private func imageRequest(token: String) -> CRUDRequest {
        let url = https("/v1.0/photos/upload")
        var request = CRUDRequest(token: token, url: url)
        request.method = .POST
        return request
    }

    
}

extension APIService {
    private final class CRUDRequest: Alamofire.URLRequestConvertible {
        
        let token: String
        let url: NSURL
        
        var additionalHeaders: [String : AnyObject]?
        var method: Alamofire.Method = .GET
        var params: [String : AnyObject]?
        var encoding: Alamofire.ParameterEncoding = .URL
        
        init(token: String, url: NSURL) {
            self.token = token
            self.url = url
        }
        
        
        var URLRequest: NSURLRequest {
            let r = NSMutableURLRequest(URL: url)
            r.HTTPMethod = method.rawValue
            var headers: [String : AnyObject] = [
                "Authorization": "Bearer \(token)",
                "Accept" : "application/json",
            ]
            if let additionalHeaders = additionalHeaders {
                for (key,value) in additionalHeaders {
                    headers.updateValue(value, forKey:key)
                }
            }
            r.allHTTPHeaderFields = headers
            return encoding.encode(r, parameters: params).0
        }
    }
}

protocol APIServiceQueryConvertible {
    var query: [String : AnyObject]  { get }
}

final class APIServiceQuery: APIServiceQueryConvertible {
    private var values: [String : AnyObject] = [:]

    func append(query newItems:APIServiceQueryConvertible) {
        for (key,value) in newItems.query {
            values.updateValue(value, forKey:key)
        }
    }
    
    var query: [String : AnyObject]  {
        return values
    }
}

extension APIService {
    struct Page: APIServiceQueryConvertible {
        let skip: Int
        let take: Int
        init(start: Int = 0, size: Int = 20) {
            skip = start
            take = size
        }
        
        func next() -> Page {
            return Page(size: take, start: skip + take)
        }
        
        var query: [String : AnyObject]  {
            return [
                "skip" : skip,
                "take" : take,
            ]
        }
    }
}
