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
import Result

struct APIService {
    
    init (
        url: NSURL,
        amazon: NSURL,
        dataProvider: NetworkDataProvider = NetworkDataProvider(),
        sessionController: SessionController = SessionController()
        ) {
            baseURL = url
            amazonURL = amazon
            self.dataProvider = dataProvider
            self.sessionController = SessionController()
    }
    
    //MARK: - Variables -
    
    private let baseURL: NSURL
    private let amazonURL: NSURL
    //TODO: make private
    internal let dataProvider: NetworkDataProvider
    internal let sessionController: SessionController
    
    var description: String {
        return "API: \(baseURL.absoluteString)"
    }
    
    
    //MARK: - Profile -
    
    func getMyProfile() -> Future<UserProfile, NSError> {
        let endpoint = UserProfile.myProfileEndpoint()
        return getObject(endpoint)
    }
    
    func updateMyProfile(object: UserProfile) -> Future<Void, NSError> {
        let endpoint = UserProfile.myProfileEndpoint()
        return updateObject(endpoint, object: object)
    }
    
    func getUserProfile(userId: CRUDObjectId) -> Future<UserProfile, NSError> {
        let endpoint = UserProfile.userEndpoint(userId)
        return getObject(endpoint)
    }
    
    //MARK: - Posts -
    
    func getUserPosts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Post>, NSError> {
        let endpoint = Post.userPostsEndpoint(userId)
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func createUserPost(post object: Post) -> Future<Post, NSError> {
        return sessionController.currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Post, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityPost(communityId: CRUDObjectId, post object: Post) -> Future<Post, NSError> {
        let endpoint = Post.communityPostsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }
    
    //MARK: - Community -
    
    func getCommunities(page: Page) -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = Community.endpoint()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }

    func getUserCommunities(userId: CRUDObjectId) -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = Community.userCommunitiesEndpoint(userId)
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getCommunity(communityId: CRUDObjectId) -> Future<Community, NSError> {
        let endpoint = Community.communityEndpoint(communityId)
        return getObject(endpoint)
    }
    
    func createCommunity(community object: Community) -> Future<Community, NSError> {
        let endpoint = Community.endpoint()
        return createObject(endpoint, object: object)
    }
    
    func updateCommunity(community object: Community) -> Future<Void, NSError> {
        let endpoint = Community.communityEndpoint(object.objectId)
        return updateObject(endpoint, object: object)
    }
    
    
    //MARK: - Search -
    
    func getFeed(query: APIServiceQueryConvertible) -> Future<CollectionResponse<FeedItem>,NSError> {
        let endpoint = FeedItem.endpoint()
        let params = query.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    //MARK: - Generics -
    
    private func getObjectsCollection<C: CRUDObject>(endpoint: String, params: [String : AnyObject]?) -> Future<CollectionResponse<C>, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<C>, NSError>)
        
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<C>, NSError> in
            let request = self.readRequest(token, endpoint: endpoint, params: params)
            let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    private func getObject<C: CRUDObject>(endpoint: String) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<C, NSError>)
        
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let request = self.readRequest(token, endpoint: endpoint)
            let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
            return future
        }
    }
    
    private func createObject<C: CRUDObject>(endpoint: String, object: C) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<UpdateResponse, NSError>)
        
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let params = Mapper().toJSON(object)
            let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
            let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request, validation: self.statusCodeValidation(statusCode: [201]))
            return future.map { (updateResponse: UpdateResponse) -> C in
                var updatedObject = object
                updatedObject.objectId = updateResponse.objectId
                return updatedObject
            }
        }
    }
    
    private func updateObject<C: CRUDObject>(endpoint: String, object: C) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<Void, NSError> in
            let params = Mapper().toJSON(object)
            let request = self.updateRequest(token, endpoint: endpoint, method: .PUT, params: params)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.emptyResponseMapping(), validation: self.statusCodeValidation(statusCode: [204]))
            return future
        }
    }
    
    //MARK: - Helpers -
    
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

    //TODO: move to request
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
    
}

//MARK: - CRUD request -
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

//MARK: - Query -

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

//MARK: - Images -

extension APIService {
    
    func uploadImage(data: NSData, dataUTI: String) -> Future<NSURL, NSError> {
        let fileInfo = NetworkDataProvider.FileUpload(data: data, dataUTI: dataUTI)
        return sessionController.session().flatMap {
            (token: AuthResponse.Token) -> Future<AnyObject?,NSError> in
            let urlRequest = self.imageRequest(token)
            return self.dataProvider.upload(urlRequest, files: [fileInfo])
            }.flatMap { (response: AnyObject?) -> Future<NSURL, NSError> in
                return future(context: ImmediateExecutionContext) { () -> Result<NSURL ,NSError> in                    
                    if  let JSON = response as? [String: AnyObject],
                        let urlString = JSON["uri"] as? String {
                            let url = self.amazonURL.URLByAppendingPathComponent(urlString)
                            return Result(value: url)
                    } else {
                        return Result(error: NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
                    }
                }
        }
    }
    
    private func imageRequest(token: String) -> CRUDRequest {
        let url = https("/v1.0/photos/upload")
        var request = CRUDRequest(token: token, url: url)
        request.method = .POST
        return request
    }

}
