//
//  DataTransforms.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

public class ListTransform<ItemTransform: TransformType>: TransformType {
    public typealias Object = [ItemTransform.Object]
    public typealias JSON = [ItemTransform.JSON]
    
    public init(itemTransform: ItemTransform) {
        self.itemTransform =  itemTransform
    }
    
    let itemTransform: ItemTransform
    
    public func transformFromJSON(value: AnyObject?) -> Object? {
        if let values = value as? [AnyObject] {
            return values.reduce(Object()) { result, item in
                if let v = itemTransform.transformFromJSON(item) {
                    return result + [v]
                }
                return result
            }
        }
        return nil
    }
    
    public func transformToJSON(value: Object?) -> JSON? {
        if let values = value {
            return values.reduce( JSON() ) { result, item in
                if let v = itemTransform.transformToJSON(item) {
                    return result + [v]
                }
                return result
            }
        }
        return nil
    }
}

public class RelativeURLTransform: TransformType {
    public init(baseURL: NSURL) {
        self.baseURL = baseURL
    }
    
    public func transformFromJSON(value: AnyObject?) -> NSURL? {
        if let URLString = value as? String {
            return NSURL(string: URLString, relativeToURL: baseURL)
        }
        return nil
    }
    
    public func transformToJSON(value: NSURL?) -> String? {
        if let URL = value,
            let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) {
                let result = components.URLRelativeToURL(baseURL)?.relativePath
                print(result)
                return result
                
        }
        return nil
    }
    
    private let baseURL: NSURL
}

