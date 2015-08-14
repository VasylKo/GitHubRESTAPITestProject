//
//  PositionInTests.swift
//  PositionInTests
//
//  Created by Alexandr Goncharov on 09/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XCTest

class PositionInTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testApi() {
        //                let username = "ios-777@bekitzur.com"
        //                let password = "pwd"
        //                api.createProfile(username: username, password: password);
        //                return true

        
    }
    /*

    func runProfileAPI() {
        var myProfileId = CRUDObjectInvalidId
        api.getMyProfile().flatMap { (profile: UserProfile) -> Future<Void,NSError> in
            myProfileId = profile.objectId
            var newProfile = profile
            newProfile.firstName = "Alex"
            newProfile.middleName = "The"
            newProfile.lastName = "Great"
            newProfile.userDescription = "User description"
            newProfile.phone = "911"
            newProfile.avatar = NSURL(string:"https://pbs.twimg.com/profile_images/3255786215/509fd5bc902d71141990920bf207edea.jpeg")!
            return self.api.updateMyProfile(newProfile)
            }.flatMap { ( _: Void ) -> Future<UserProfile,NSError> in
                return self.api.get(myProfileId)
            }.onSuccess { profile in
                Log.info?.value(profile)
                self.runPostsAPI(profile)
            }.onFailure { error in
                Log.error?.value(error)
        }
    }
    
    func runPostsAPI(user: UserProfile) {
        self.api.getUserPosts(user.objectId, page: APIService.Page())
            .flatMap { (response) -> Future<Post, NSError> in
                var post = Post(objectId: CRUDObjectInvalidId)
                post.name = "Cool post"
                post.text = "Big Post text"
                return self.api.createUserPost(user.objectId, post: post)
            }.flatMap { (_: Post) -> Future<CollectionResponse<FeedItem>,NSError> in
                return self.api.getFeed(APIService.Page())
                
            }.onSuccess { response in
                Log.info?.value(response.items)
            }.onFailure { error in
                Log.error?.value(error)
        }
        
        //            .onSuccess { post in
        //            Log.debug?.value(post)
        //        }.onFailure { error in
        //           Log.error?.value(error)
        //        }
    }
    */    
}
