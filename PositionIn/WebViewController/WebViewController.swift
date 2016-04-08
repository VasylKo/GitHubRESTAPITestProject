//
//  WebViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 31/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var webView: UIWebView!
    var contentURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = contentURL {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
            self.spinner.startAnimating()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.spinner.stopAnimating()
    }
    
    func didFailLoadWithError(webView: UIWebView, error: NSError?) {
        self.spinner.stopAnimating()
        if let error = error {
            showError(error.description)
        }
    }
}