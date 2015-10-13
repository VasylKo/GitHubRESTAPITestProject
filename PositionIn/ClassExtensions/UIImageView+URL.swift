//
//  UIImageView+URL.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 04/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import Haneke

extension UIImageView {
    func setImageFromURL(url: NSURL?, placeholder: UIImage? = nil) {        
        if let url = url {
            let fetcher = ImageNetworkFetcher<UIImage>(URL: url)
            self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder)            
        } else {
            self.image = placeholder
        }

    }
}

class ImageNetworkFetcher<T: DataConvertible>: NetworkFetcher<T> {
    override init(URL : NSURL) {
        super.init(URL: URL)
    }
    
    override var session : NSURLSession {
        return imageURLSession
    }
    
}

private let imageURLSession: NSURLSession = {
    class ImageURLSessionDelegate: NSObject, NSURLSessionDelegate {
        func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
            let serverTrust = challenge.protectionSpace.serverTrust!
            completionHandler(.UseCredential, NSURLCredential(forTrust: serverTrust))
        }
        
    }
    return NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: ImageURLSessionDelegate(),
        delegateQueue: nil)
    }()
