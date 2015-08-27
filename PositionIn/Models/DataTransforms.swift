//
//  DataTransforms.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

final class APIDateTransform: DateFormaterTransform {
    
    init() {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.ZZZ'Z'"
        
        super.init(dateFormatter: formatter)
    }
    
}


class RelativeURLTransform: TransformType {
    init(baseURL: NSURL) {
        self.baseURL = baseURL
    }
    
    func transformFromJSON(value: AnyObject?) -> NSURL? {
        if let URLString = value as? String {
            return NSURL(string: URLString, relativeToURL: baseURL)
        }
        return nil
    }
    
    func transformToJSON(value: NSURL?) -> String? {
        if let URL = value,
           let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) {
            let result = components.URLRelativeToURL(baseURL)?.relativePath
            println(result)
            return result
        
        }
        return nil
    }
    
    private let baseURL: NSURL
}

class AmazonURLTransform: RelativeURLTransform {
    init() {
        super.init(baseURL: AppConfiguration().amazonURL)
    }
}