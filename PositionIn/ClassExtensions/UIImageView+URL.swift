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
        let scale = UIScreen.mainScreen().scale
        let viewSize = frame.size
        let targetImageViewSize = CGSizeMake(viewSize.width * scale, viewSize.height * scale)
        
        // TODO: Need to create extension for create NSURL with parameters
        let parameters = "?w=\(Int(targetImageViewSize.width))&h=\(Int(targetImageViewSize.height))"
        let urlWithTargetSize = NSURL(string: parameters, relativeToURL: url)
        
        if let url = urlWithTargetSize {
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
        
        @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            let serverTrust = challenge.protectionSpace.serverTrust!
            completionHandler(.UseCredential, NSURLCredential(forTrust: serverTrust))
        }
        
    }
    return NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: ImageURLSessionDelegate(),
        delegateQueue: nil)
    }()
