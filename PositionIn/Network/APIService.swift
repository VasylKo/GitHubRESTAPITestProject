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
    func session() -> Future<Void ,NSError> {
        return sessionController.session().map() { _ in
            return ()
        }
    }
    
    func getMyProfile() -> Future<UserProfile, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<UserProfile,NSError> in
            let request = self.crudRequest(token, endpoint: UserProfile.myProfileEndpoint(), method: .GET, params: nil)
            let (_ , future): (Alamofire.Request, Future<UserProfile,NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    func updateMyProfile(object: UserProfile) -> Future<Void,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Void,NSError> in
            let urlRequest = self.crudRequest(token, endpoint: UserProfile.myProfileEndpoint(), method: .PUT, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<Void, NSError>) = self.dataProvider.jsonRequest(urlRequest, map: self.emptyResponseMapping())
            request.validate(statusCode: [204])
            return future
        }
    }
    
    //TODO: use Page
    func getUserPosts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Post>,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<Post>, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            let request = self.crudRequest(token, endpoint: endpoint, method: .GET, params: nil)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<Post>, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    
    //TODO: check usage
    func getAll<C: CRUDObject>(endpoint: String) -> Future<CollectionResponse<C>, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<C>,NSError> in
            let request = self.crudRequest(token, endpoint: endpoint, method: .GET, params: nil)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<C>, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    func get<C: CRUDObject>(objectID: CRUDObjectId) -> Future<C, NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let request = self.crudRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(objectID), method: .GET, params: nil)
            let (_ , future): (Alamofire.Request, Future<C, NSError>) = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    func update<C: CRUDObject>(object: C) -> Future<Void,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Void,NSError> in
            let urlRequest = self.crudRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(object.objectId), method: .PUT, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<Void, NSError>) = self.dataProvider.jsonRequest(urlRequest, map: self.emptyResponseMapping())
            request.validate(statusCode: [204])
            return future
        }
    }

    //TODO: check usage
    func post<C: CRUDObject>(object: C) -> Future<C,NSError> {
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C,NSError> in
            let urlRequest = self.crudRequest(token, endpoint: C.endpoint(), method: .POST, params: Mapper().toJSON(object))
            let (request, future): (Alamofire.Request, Future<C, NSError>) = self.dataProvider.objectRequest(urlRequest)
            request.validate(statusCode: [201])
            return future
        }
    }
    
    private func crudRequest(token: String, endpoint: String, method: Alamofire.Method, params: [String : AnyObject]?) -> NSURLRequest {
        let url = self.https(endpoint)
        let headers: [String : AnyObject] = [
            "Authorization": "Bearer \(token)",
            "Accept" : "application/json",
        ]
        let r = NSMutableURLRequest(URL: url)
        r.HTTPMethod = method.rawValue
        r.allHTTPHeaderFields = headers
        let encoding = Alamofire.ParameterEncoding.JSON
        return encoding.encode(r, parameters: params).0
    }
    
    internal func http(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "http")
    }
    
    internal func https(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "https")
    }
    
    var description: String {
        return "API: \(baseURL.absoluteString)"
    }
    
    init (url: NSURL, dataProvider: NetworkDataProvider = NetworkDataProvider()) {
        baseURL = url
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
//TODO: make private
    internal let dataProvider: NetworkDataProvider
    internal let sessionController: SessionController
    
}

extension APIService {
    struct Page {
        let skip: Int
        let take: Int
        init(start: Int = 0, size: Int = 20) {
            skip = start
            take = size
        }
        
        func next() -> Page {
            return Page(size: take, start: skip + take)
        }
    }
}
