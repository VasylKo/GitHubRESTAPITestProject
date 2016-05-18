//
//  Fetcher.swift
//  PositionIn
//
//  Created by iam on 23/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures

protocol Fetcher {
    typealias FetchedObject : CRUDObject
    func fetch(limit: Int, offset: Int, searchString: String?) -> Future<CollectionResponse<FetchedObject>, NSError>
}

class ExploreUserFetcher : Fetcher {
    func fetch(limit: Int, offset: Int, searchString: String? = nil) -> Future<CollectionResponse<UserInfo>, NSError> {
        let page = APIService.Page(start: offset, size: limit)
        
        return api().getUsers(page, searchString: searchString)
    }
}