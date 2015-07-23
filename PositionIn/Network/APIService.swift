//
//  APIService.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

struct API: APIService {
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
}