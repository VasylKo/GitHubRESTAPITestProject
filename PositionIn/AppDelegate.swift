//
//  AppDelegate.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 09/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import Alamofire



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?


    let api: APIService
    var token: String?
    
    override init() {
        let baseURL = NSURL(string: "http://45.63.7.39:8080")!
        api = APIService(url: baseURL)
        super.init()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let username = "ios-777@bekitzur.com"
        let password = "pwd"
        
        
        let createCompletion: (OperationResult<Bool>)->Void = { result in
            switch result {
            case .Failure(let error):
                println(error)
            case .Success(_):
                println("Register Success: got \(result.value)")
            }
        }
        
        let getSpecProfileCompletion: (OperationResult<UserProfile>)->Void = { result in
            switch result {
            case .Failure(let error):
                println(error)
            case .Success(_):
                println("Get profile Success: got \(result.value)")
            }
        }

        let getProfileCompletion: (OperationResult<UserProfile>)->Void = { result in
            switch result {
            case .Failure(let error):
                println(error)
            case .Success(_):
                println("Get profile Success: got \(result.value)")
                self.api.get(self.token!, objectID: result.value.objectId, completion: getSpecProfileCompletion)
            }
        }
        
        
        let authCompletion: (OperationResult<APIService.AuthResponse>)->Void = { result in
            switch result {
            case .Failure(let error):
                println(error)
            case .Success(_):
                let auth = result.value
                println("Auth Success: got \(auth)")
                self.token = auth.accessToken

                self.api.get(self.token!, objectID: nil, completion: getProfileCompletion)
            }
        }


        //api.createProfile(username: username, password: password, completion: createCompletion)
        api.auth(username: username, password: password, completion: authCompletion)
        
        
        if let sidebarViewController = window?.rootViewController as? SidebarViewController {
            let defaultAction: SidebarViewController.Action = .ForYou
            sidebarViewController.executeAction(defaultAction)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

