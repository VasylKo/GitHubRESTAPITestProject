//
//  Gist.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import SwiftyJSON

class Gist: NSObject, NSCoding, ResponseJSONObjectSerializable {
    var id: String?
    var gistDescription: String?
    var ownerLogin: String?
    var ownerAvatarURL: String?
    var url: String?
    var files:[File]?
    var createdAt:NSDate?
    var updatedAt:NSDate?
    
    private lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    //MARK: - NSCoding
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(gistDescription, forKey: "gistDescription")
        aCoder.encodeObject(ownerLogin, forKey: "ownerLogin")
        aCoder.encodeObject(ownerAvatarURL, forKey: "ownerAvatarURL")
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeObject(createdAt, forKey: "createdAt")
        aCoder.encodeObject(updatedAt, forKey: "updatedAt")
        if let files = files {
            aCoder.encodeObject(files, forKey: "files")
        }
    }
    
    required override init() {
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        id = aDecoder.decodeObjectForKey("id") as? String
        gistDescription = aDecoder.decodeObjectForKey("gistDescription") as? String
        ownerLogin = aDecoder.decodeObjectForKey("ownerLogin") as? String
        ownerAvatarURL = aDecoder.decodeObjectForKey("ownerAvatarURL") as? String
        createdAt = aDecoder.decodeObjectForKey("createdAt") as? NSDate
        updatedAt = aDecoder.decodeObjectForKey("updatedAt") as? NSDate
        if let files = aDecoder.decodeObjectForKey("files") as? [File] {
            self.files = files
        }
    }
    
    //MARK: - ResponseJSONObjectSerializable
    required init?(json: JSON) {
        super.init()
        
        if let description = json["description"].string where !description.isEmpty {
            gistDescription = description
        } else {
            gistDescription = "No description"
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
