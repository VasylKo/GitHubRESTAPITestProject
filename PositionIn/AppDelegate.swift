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
import Messaging
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private(set) var api: APIService
    let chatClient: XMPPClient
    let locationController: LocationController
    
    var sidebarViewController: SidebarViewController? {
        return self.window?.rootViewController as? SidebarViewController
    }
    
    override init() {
        #if DEBUG
        Log.enable(minimumSeverity: .Verbose, synchronousMode: true)
        #else
        Log.enable(minimumSeverity: .Info, synchronousMode: false)
        #endif
        let urlSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let baseURL = AppConfiguration().baseURL
        //FIXME: dissallow self signed certificates in the future
        let trustPolicies: [String: ServerTrustPolicy]? = [
            baseURL.host! : .DisableEvaluation
            ]
        let dataProvider = PosInCore.NetworkDataProvider(configuration: urlSessionConfig, trustPolicies: trustPolicies)
        api = APIService(url: baseURL, dataProvider: dataProvider)
        let chatConfig = XMPPClientConfiguration.defaultConfiguration()
        chatClient = XMPPClient(configuration: chatConfig)
        locationController = LocationController()
        super.init()
    }

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupMaps()
        api.defaultErrorHandler = UIErrorHandler()
        if SearchFilter.isCustomLocationSet == false {
           SearchFilter.updateCurrentLocation()
        }
        api.recoverSession().onSuccess { [unowned self] _ in
            self.sidebarViewController?.executeAction(SidebarViewController.defaultAction)
        }.onFailure { [unowned self] error in
            Log.error?.value(error)
            self.sidebarViewController?.executeAction(.Login)
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
    
    func UIErrorHandler() -> APIService.ErrorHandler {
        return { [unowned self] error in
            Log.error?.value(error)
            let baseErrorDomain: String = NetworkDataProvider.ErrorCodes.errorDomain
            switch (error.domain, error.code) {
            case (baseErrorDomain, NetworkDataProvider.ErrorCodes.InvalidSessionError.rawValue):
                self.sidebarViewController?.executeAction(.Login)
                showError(error.localizedDescription)
            default:
                showWarning(error.localizedDescription)
            }
        }
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

func chat() -> XMPPClient {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.chatClient
}