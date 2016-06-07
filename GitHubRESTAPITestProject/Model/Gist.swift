//
//  Gist.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import SwiftyJSON

class Gist: ResponseJSONObjectSerializable {
    var id: String?
    var description: String?
    var ownerLogin: String?
    var ownerAvatarURL: String?
    var url: String?
    var files:[File]?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    
    private lazy var dateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    required init(json: JSON) {
        if let description = json["description"].string where !description.isEmpty {
            self.description = description
        } else {
            description = "No description"
        }
        
        if let ownerLogin = json["owner"]["login"].string where !ownerLogin.isEmpty {
            self.ownerLogin = ownerLogin
        } else {
            ownerLogin = "Unknown owner name"
        }

        id = json["id"].string
        ownerAvatarURL = json["owner"]["avatar_url"].string
        url = json["url"].string
        
        files = [File]()
        if let filesJSON = json["files"].dictionary {
            for (_, fileJSON) in filesJSON {
                guard let newFile = File(json: fileJSON) else { continue }
                files?.append(newFile)
            }
        }
        
        if let dateString = json["created_at"].string {
            createdAt = dateFormatter.dateFromString(dateString)
        }
        
        if let dateString = json["updated_at"].string {
            updatedAt = dateFormatter.dateFromString(dateString)
        }
    }
}
