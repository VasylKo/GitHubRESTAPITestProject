//
//  File.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 06/06/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import SwiftyJSON

class File: NSObject, NSCoding, ResponseJSONObjectSerializable {
    var filename: String?
    var raw_url: String?
    var content: String?
    
    //MARK: - ResponseJSONObjectSerializable
    required init?(json: JSON) {
        filename = json["filename"].string
        raw_url = json["raw_url"].string
    }
    
    init(name: String?, content: String?) {
        filename = name
        self.content = content
    }
    
    //MARK: - NSCoding
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(filename, forKey: "filename")
        aCoder.encodeObject(raw_url, forKey: "raw_url")
        aCoder.encodeObject(content, forKey: "content")
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let filename = aDecoder.decodeObjectForKey("filename") as? String
        let content = aDecoder.decodeObjectForKey("content") as? String
        
        self.init(name: filename, content: content)
        raw_url = aDecoder.decodeObjectForKey("raw_url") as? String
    }
}