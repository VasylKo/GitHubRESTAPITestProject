//
//  File.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 06/06/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import SwiftyJSON

class File: ResponseJSONObjectSerializable {
    var filename: String?
    var raw_url: String?
    var content: String?
    
    required init?(json: JSON) {
        filename = json["filename"].string
        raw_url = json["raw_url"].string
    }
    
    init(name: String?, content: String?) {
        filename = name
        self.content = content
    }
}