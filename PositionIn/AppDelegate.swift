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
import BrightFutures
import CleanroomLogger
import ResponseDetective
import Messaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let api: APIService
    let chatClient: XMPPClient
    
    override init() {
        #if DEBUG
        Log.enable(minimumSeverity: .Verbose, synchronousMode: true)
        #else
        Log.enable(minimumSeverity: .Info, synchronousMode: false)
        #endif
        let urlSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        #if DEBUG
        InterceptingProtocol.registerRequestInterceptor(HeadersInterceptor(outputStream: CleanroomOutputStream(logChannel: Log.debug)))
        InterceptingProtocol.registerRequestInterceptor(JSONInterceptor(outputStream: CleanroomOutputStream(logChannel: Log.debug)))
        InterceptingProtocol.registerErrorInterceptor(HeadersInterceptor(outputStream: CleanroomOutputStream(logChannel: Log.error)))
        urlSessionConfig.protocolClasses = [InterceptingProtocol.self]
        #endif
        let baseURL = NSURL(string: "http://45.63.7.39:8080")!
        
        let dataProvider = PosInCore.NetworkDataProvider(configuration: urlSessionConfig)
        api = APIService(url: baseURL, dataProvider: dataProvider)
        let chatConfig = XMPPClientConfiguration.defaultConfiguration()
        chatClient = XMPPClient(configuration: chatConfig)
        super.init()
    }

    
    func runProfileAPI() {
        
        api.get(nil).flatMap { (profile: UserProfile) -> Future<Void,NSError> in
            var newProfile = profile
            newProfile.firstName = "Alex"
            newProfile.middleName = "The"
            newProfile.lastName = "Great"
            return self.api.update(newProfile)
        }.flatMap { ( _: Void ) -> Future<UserProfile,NSError> in
                return self.api.get(nil)
        }.onSuccess { profile in
            Log.info?.value(profile)
            self.runPostsAPI(profile)
        }.onFailure { error in
            Log.error?.value(error)
        }
    }
    
    func runPostsAPI(user: UserProfile) {
        var post = Post(objectId: CRUDObjectInvalidId)
        post.name = "Cool post"
        post.text = "Big Post text"
        
        api.post(post).flatMap { ( _: Void ) -> Future<CollectionResponse<Post>, NSError> in
            return self.api.getAll(Post.allEndpoint(user.objectId))
        }.onSuccess { response in
            Log.info?.value(response.items)
        }.onFailure { error in
            Log.error?.value(error)
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        api.sessionController.session().recoverWith { [unowned self]
            (error: NSError) -> Future<APIService.AuthResponse.Token ,NSError>  in
            Log.error?.value(error)
            let username = "ios-777@bekitzur.com"
            let password = "pwd"
            return self.api.auth(username: username, password: password).map { response in
                return response.accessToken
            }
        }.onSuccess { _ in
            self.runProfileAPI()
        }.onFailure { error in
            Log.error?.value(error)
        }
                


//        self.chatClient.auth("ixmpp@beewellapp.com", password: "1HateD0m2").future().onSuccess {
//            Log.info?.message("XMPP authorized")
//            }.onFailure { error in
//                Log.error?.value(error)
//        }
        

        
        
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

func api() -> APIService {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.api
}


struct CleanroomOutputStream: OutputStreamType {
    let logChannel: LogChannel?
    func write(string: String) {
        logChannel?.message(string)
    }
}