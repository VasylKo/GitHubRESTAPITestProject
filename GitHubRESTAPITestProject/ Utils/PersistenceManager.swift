//
//  PersistenceManager.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 16.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation

class PersistenceManager {
    enum Path: String {
        case publicGists = "Public"
        case starredGists = "Starred"
        case myGists = "MyGists"
    }
    
    static private func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }
    
    static func saveArray<T: NSCoding>(arrayToSave: [T], path: Path) {
        let file = documentsDirectory().stringByAppendingPathComponent(path.rawValue)
        NSKeyedArchiver.archiveRootObject(arrayToSave, toFile: file)
    }
    
    static func loadArray<T: NSCoding>(path: Path) -> [T]? {
        let file = documentsDirectory().stringByAppendingPathComponent(path.rawValue)
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(file)
        return result as? [T]
    }
}