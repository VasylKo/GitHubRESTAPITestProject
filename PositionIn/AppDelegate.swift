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
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let api: APIService
    let chatClient: XMPPClient
    let locationController: LocationController
    
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
//        urlSessionConfig.protocolClasses = [InterceptingProtocol.self]
        #endif
        let baseURL = NSURL(string: "https://app-dev.positionin.com/api/")!
        let amazonURL = NSURL(string: "https://pos-dev.s3.amazonaws.com/")!
        #if DEBUG
        let trustPolicies: [String: ServerTrustPolicy]? = [
            baseURL.host! : .DisableEvaluation
            ]
        #else
        let trustPolicies: [String: ServerTrustPolicy]? = nil
        #endif
        let dataProvider = PosInCore.NetworkDataProvider(configuration: urlSessionConfig, trustPolicies: trustPolicies)
        api = APIService(url: baseURL, amazon: amazonURL, dataProvider: dataProvider)
        let chatConfig = XMPPClientConfiguration.defaultConfiguration()
        chatClient = XMPPClient(configuration: chatConfig)
        locationController = LocationController()
        super.init()
    }

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupMaps()
        api.getMyProfile().onComplete { result in
            let defaultAction: SidebarViewController.Action
            if let profile = result.value {
                defaultAction = .ForYou
            } else {
                defaultAction = .Login
            }
            if let sidebarViewController = self.window?.rootViewController as? SidebarViewController {
                sidebarViewController.executeAction(defaultAction)
            }
        }
        
        return true
                
        self.chatClient.auth("ixmpp@beewellapp.com", password: "1HateD0m2").future().onSuccess { [unowned self] in
            Log.info?.message("XMPP authorized")
            self.chatClient.sendTestMessage()
            }.onFailure { error in
                Log.error?.value(error)
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

extension AppDelegate {
    func setupMaps() {
        let apiKey = "AIzaSyA3NvrDKBcpIsnq4-ZACG41y7Mj-wSfVrY"
        GMSServices.provideAPIKey(apiKey)
    }
}

func api() -> APIService {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.api
}

func locationController() -> LocationController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.locationController
}


struct CleanroomOutputStream: OutputStreamType {
    let logChannel: LogChannel?
    func write(string: String) {
        logChannel?.message(string)
    }
}
