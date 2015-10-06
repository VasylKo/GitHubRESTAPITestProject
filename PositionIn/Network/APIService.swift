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
        dataProvider: NetworkDataProvider = NetworkDataProvider(),
        sessionController: SessionController = SessionController()
        ) {
            baseURL = url
            self.dataProvider = dataProvider
            self.sessionController = sessionController
    }
    
    //MARK: - Error handling -
    
    typealias ErrorHandler = (NSError) -> ()
    
    var defaultErrorHandler: ErrorHandler?
    
    func handleFailure<R>(future: Future<R, NSError>) -> Future<R, NSError> {
        return future.onFailure { error in
            if let e = NetworkDataProvider.ErrorCodes.fromError(error) where e == .InvalidSessionError {
                self.logout()
            }
            self.defaultErrorHandler?(error)
        }
    }
    
    //MARK: - Variables -
    
    private let baseURL: NSURL
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
    
    func getPost(postId: CRUDObjectId) -> Future<Post, NSError> {
        let endpoint = Post.endpoint(postId)
        return getObject(endpoint)
    }
    
    func createUserPost(post object: Post) -> Future<Post, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Post, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityPost(communityId: CRUDObjectId, post object: Post) -> Future<Post, NSError> {
        let endpoint = Post.communityPostsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }
    
    func likePost(postId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Post.likeEndpoint(postId)
        return updateCommand(endpoint)
    }
    
    func unlikePost(postId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Post.likeEndpoint(postId)
        return updateCommand(endpoint, method: .DELETE)
    }
    
    func createPostComment(postId: CRUDObjectId, object: Comment) -> Future<Comment, NSError> {
        let endpoint = Post.postCommentEndpoint(postId)
        return createObject(endpoint, object: object)
    }
    
    //MARK: - Promotions -
    
    func getUserPromotions(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Promotion>, NSError> {
        let endpoint = Promotion.endpoint()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func createUserPromotion(object: Promotion) -> Future<Promotion, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Promotion, NSError> in
            let endpoint = Promotion.userPromotionsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityPromotion(communityId: CRUDObjectId, promotion object: Promotion) -> Future<Promotion, NSError> {
        let endpoint = Promotion.communityPromotionsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }

    func getPromotion(objectId: CRUDObjectId) -> Future<Promotion, NSError> {
        let endpoint = Promotion.endpoint(objectId)
        return getObject(endpoint)
    }
    
    //MARK: - Events -
    
    func getUserEvents(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Event>, NSError> {
        let endpoint = Event.userEventsEndpoint(userId)
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func createUserEvent(object: Event) -> Future<Event, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Event, NSError> in
            let endpoint = Event.userEventsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityEvent(communityId: CRUDObjectId, event object: Event) -> Future<Event, NSError> {
        let endpoint = Event.communityEventsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }

    func getEvent(objectId: CRUDObjectId) -> Future<Event, NSError> {
        let endpoint = Event.endpoint(objectId)
        return getObject(endpoint)
    }
    
    //MARK: - Products -
    
    func getUserProducts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Product>, NSError> {
       return self.getUserProfile(userId).flatMap { profile -> Future<CollectionResponse<Product>, NSError> in
            let endpoint = Product.shopItemsEndpoint(profile.defaultShopId)
            let params = page.query
            return self.getObjectsCollection(endpoint, params: params)
        }
    }
    
    
    func createProduct(object: Product, inShop shop: CRUDObjectId) -> Future<Product, NSError> {
        let endpoint = Product.shopItemsEndpoint(shop)
        return self.createObject(endpoint, object: object)
    }
    
    
    func getProduct(objectId: CRUDObjectId, inShop shop: CRUDObjectId) -> Future<Product, NSError> {
            let endpoint = Product.shopItemsEndpoint(shop, productId: objectId)
            return self.getObject(endpoint)
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
    
    func joinCommunity(communityId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Community.membersEndpoint(communityId)
        return updateCommand(endpoint)
    }
    
    //MARK: - People -
    
    func getUsers(page: Page) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.endpoint()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func getUsers(userIds: [CRUDObjectId]) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.endpoint()
        let params = APIServiceQuery()
        params.append("ids", value: userIds)
        
        //TODO: refactor, use generics
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<UserInfo>, NSError>)        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<UserInfo>, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
            let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    func getMySubscriptions() -> Future<CollectionResponse<UserInfo>,NSError> {
        return currentUserId().flatMap { userId in
            return self.getUserSubscriptions(userId)
        }
    }
    
    func getUserSubscriptions(userId: CRUDObjectId) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getSubscriptionStateForUser(userId: CRUDObjectId) -> Future<UserProfile.SubscriptionState, NSError> {
        //TODO: use follow":true from user profile response
        if isCurrentUser(userId) {
            return future { () -> Result<UserProfile.SubscriptionState, NSError> in
                return Result(value:.SameUser)
            }
        }
        return getMySubscriptions().map { (response: CollectionResponse<UserInfo>) -> UserProfile.SubscriptionState in
            if count( response.items.filter { $0.objectId == userId } ) > 0 {
                return .Following
            } else {
                return .NotFollowing
            }
        }
    }
    
    func followUser(userId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return updateCommand(endpoint)
    }

    func unFollowUser(userId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return updateCommand(endpoint, method: .DELETE)
    }

    
    //MARK: - Search -
    
    func getSearchFeed(query: APIServiceQueryConvertible, page: Page) -> Future<QuickSearchResponse,NSError> {
        let endpoint = SearchItem.endpoint()
        let params = APIServiceQuery()
        params.append(query: query)
        params.append(query: page)
        Log.debug?.value(params.query)
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<QuickSearchResponse, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
            let (_ , future): (Alamofire.Request, Future<QuickSearchResponse, NSError>) = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    func getFeed(query: APIServiceQueryConvertible, page: Page) -> Future<CollectionResponse<FeedItem>,NSError> {
        let endpoint = FeedItem.endpoint()
        let params = APIServiceQuery()
        params.append(query: query)
        params.append(query: page)
        Log.debug?.value(params.query)
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<FeedItem>, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<FeedItem>, NSError>) = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    func forYou(query: APIServiceQueryConvertible, page: Page) -> Future<CollectionResponse<FeedItem>,NSError> {
        let endpoint = FeedItem.forYouEndpoint()
        let params = APIServiceQuery()
        params.append(query: query)
        params.append(query: page)
        Log.debug?.value(params.query)
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<FeedItem>, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
            let (_ , future): (Alamofire.Request, Future<CollectionResponse<FeedItem>, NSError>) = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    //MARK: - Generic requests -
    
    private func getObjectsCollection<C: CRUDObject>(endpoint: String, params: [String : AnyObject]?) -> Future<CollectionResponse<C>, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<C>, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<CollectionResponse<C>, NSError> in
            let request = self.readRequest(token, endpoint: endpoint, params: params)
            let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    private func getObject<C: CRUDObject>(endpoint: String) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<C, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let request = self.readRequest(token, endpoint: endpoint)
            let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
            return self.handleFailure(future)
        }
    }
    
    private func createObject<C: CRUDObject>(endpoint: String, object: C) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<UpdateResponse, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<C, NSError> in
            let params = Mapper().toJSON(object)
            let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
            let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
            return self.handleFailure(future.map { (updateResponse: UpdateResponse) -> C in
                var updatedObject = object
                updatedObject.objectId = updateResponse.objectId
                return updatedObject
            })
        }
    }

    
    private func updateCommand(endpoint: String, method: Alamofire.Method = .POST) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<Void, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, method: method, params: nil)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: self.statusCodeValidation(statusCode: [201]))
            return self.handleFailure(future)
        }
    }

    
    private func updateObject<C: CRUDObject>(endpoint: String, object: C) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<Void, NSError> in
            let params = Mapper().toJSON(object)
            let request = self.updateRequest(token, endpoint: endpoint, method: .PUT, params: params)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.emptyResponseMapping(), validation: self.statusCodeValidation(statusCode: [204]))
            return self.handleFailure(future)
        }
    }
    
    //MARK: - Helpers -
    
//TODO:    @availability(*, unavailable)
    private func emptyResponseMapping() -> (AnyObject? -> Void?) {
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
    
    private func commandMapping() -> (AnyObject? -> Void?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let success = json["success"] as? Bool where success == true{
                        return ()
                } else {
                    Log.error?.message("Got unexpected response")
                    Log.debug?.value(json)
                    return nil
                }
            }
            //TODO: need handle nil response
            else if response == nil {
                return ()
            }
            else {
                Log.error?.message("Got unexpected response: \(response)")
                return nil
            }
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

extension APIService {
    
    final class APIServiceQuery: APIServiceQueryConvertible {
        private var values: [String : AnyObject] = [:]

        func append(query newItems:APIServiceQueryConvertible) {
            for (key,value) in newItems.query {
                values.updateValue(value, forKey:key)
            }
        }
        
        func append(key: String, value: AnyObject) {
            values.updateValue(value, forKey:key)
        }
        
        var query: [String : AnyObject]  {
            return values
        }
    }
}

extension APIService {
    
    struct Page: APIServiceQueryConvertible {
        let skip: Int
        let take: Int
        init(start: Int = 0, size: Int = 100) {
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
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<AnyObject?,NSError> in
            let urlRequest = self.imageRequest(token)
            return self.dataProvider.upload(urlRequest, files: [fileInfo])
            }.flatMap { (response: AnyObject?) -> Future<NSURL, NSError> in
                return future(context: ImmediateExecutionContext) { () -> Result<NSURL ,NSError> in                    
                    if  let JSON = response as? [String: AnyObject],
                        let url = AmazonURLTransform().transformFromJSON(JSON["url"]) {
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
