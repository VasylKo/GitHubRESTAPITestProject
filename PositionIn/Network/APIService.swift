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
    
    func get<C: CRUDObject>(token: String, objectID: CRUDObjectId?, completion: (OperationResult<C>)->Void) {
        let endpoint = C.endpoint().stringByAppendingPathComponent(objectID ?? "")
        let url = self.http(endpoint)
        let headers: [String : AnyObject] = [
            "Authorization": "Bearer \(token)",
            "Accept" : "application/json",
        ]
        let method: Alamofire.Method = .GET
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        dataProvider.objectRequest(request, completion: completion)
    }
    
    func update<C: CRUDObject>(token: String, object: C,  completion: (OperationResult<Void>)->Void) {
        let url = self.http(C.endpoint().stringByAppendingPathComponent(object.objectId))
        let headers: [String : AnyObject] = [
            "Authorization": "Bearer \(token)",
            "Accept" : "application/json",
        ]
        let params = Mapper().toJSON(object)
        let method: Alamofire.Method = .PUT
        let request: NSURLRequest = {
           let r = NSMutableURLRequest(URL: url)
            r.HTTPMethod = method.rawValue
            r.allHTTPHeaderFields = headers
            let encoding = Alamofire.ParameterEncoding.JSON
            return encoding.encode(r, parameters: params).0
        }()
        dataProvider.jsonRequest(request, map: emptyResponseMapping(), completion: completion).validate(statusCode: [204])
    }
    
    func post<C: CRUDObject>(token: String, object: C,  completion: (OperationResult<Void>)->Void) {
        let url = self.http(C.endpoint())
        let headers: [String : AnyObject] = [
            "Authorization": "Bearer \(token)",
            "Accept" : "application/json",
        ]
        let params = Mapper().toJSON(object)
        let method: Alamofire.Method = .POST
        let request: NSURLRequest = {
            let r = NSMutableURLRequest(URL: url)
            r.HTTPMethod = method.rawValue
            r.allHTTPHeaderFields = headers
            let encoding = Alamofire.ParameterEncoding.JSON
            return encoding.encode(r, parameters: params).0
            }()
        dataProvider.jsonRequest(request, map: emptyResponseMapping(), completion: completion).validate(statusCode: [201])
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
                    println("Error: \(errorMessage)")
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