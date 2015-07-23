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


struct APIService {
    
    func getAll<C: CRUDObject>(token: String, endpoint: String, completion: (OperationResult<CollectionResponse<C>>)->Void) {
        let request = crudRequest(token, endpoint: endpoint, method: .GET, params: nil)
        dataProvider.objectRequest(request, completion: completion)
    }
    
    func get<C: CRUDObject>(token: String, objectID: CRUDObjectId?, completion: (OperationResult<C>)->Void) {
        let request = crudRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(objectID ?? ""), method: .GET, params: nil)
        dataProvider.objectRequest(request, completion: completion)
    }
    
    func update<C: CRUDObject>(token: String, object: C,  completion: (OperationResult<Void>)->Void) {
        let request = crudRequest(token, endpoint: C.endpoint().stringByAppendingPathComponent(object.objectId), method: .PUT, params: Mapper().toJSON(object))
        dataProvider.jsonRequest(request, map: emptyResponseMapping(), completion: completion).validate(statusCode: [204])
    }
    
    func update(token: String, object: UserProfile,  completion: (OperationResult<Void>)->Void) {
        let request = crudRequest(token, endpoint: UserProfile.endpoint(), method: .PUT, params: Mapper().toJSON(object))
        dataProvider.jsonRequest(request, map: emptyResponseMapping(), completion: completion).validate(statusCode: [204])
    }

    
    func post<C: CRUDObject>(token: String, object: C,  completion: (OperationResult<Void>)->Void) {
        let request = crudRequest(token, endpoint: C.endpoint(), method: .POST, params: Mapper().toJSON(object))
        dataProvider.jsonRequest(request, map: emptyResponseMapping(), completion: completion).validate(statusCode: [201])
    }
    
    private func crudRequest(token: String, endpoint: String, method: Alamofire.Method, params: [String : AnyObject]?) -> NSURLRequest {
        let url = self.http(endpoint)
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
    
    
    //TODO: make private
    func http(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "http")
    }
    
    func https(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "https")
    }
    
    var description: String {
        return "API: \(baseURL.absoluteString)"
    }
    
    init (url: NSURL) {
        baseURL = url
        dataProvider = NetworkDataProvider()
    }
    
    func emptyResponseMapping() -> (AnyObject? -> Void?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let errorMessage = json["message"] as? String {
                    println("Server Error: \(errorMessage)")
                } else {
                    println("Got unexpected answer: \(json)")
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
    let dataProvider: NetworkDataProvider
}

struct CollectionResponse<C: CRUDObject>: Mappable {
    private(set) var items: [C]?
    
    init?(_ map: Map) {
        mapping(map)
        switch (items) {
        case (.Some):
            break
        default:
            println("Error while parsing object \(self)")
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        items <- map["data"]
    }

}
