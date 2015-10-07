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
    private(set) var chatClient: XMPPClient
    let locationController: LocationController
    private var userDidChangeObserver: NSObjectProtocol!
    
    var sidebarViewController: SidebarViewController? {
        return self.window?.rootViewController as? SidebarViewController
    }
    
    override init() {
        #if DEBUG
        Log.enable(minimumSeverity: .Verbose, synchronousMode: true)
        #else
        Log.enable(minimumSeverity: .Info, synchronousMode: false)
        #endif
        let appConfig = AppConfiguration()
        let urlSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let baseURL = appConfig.baseURL
        //FIXME: dissallow self signed certificates in the future
        let trustPolicies: [String: ServerTrustPolicy]? = [
            baseURL.host! : .DisableEvaluation
            ]
        let dataProvider = PosInCore.NetworkDataProvider(configuration: urlSessionConfig, trustPolicies: trustPolicies)
        api = APIService(url: baseURL, dataProvider: dataProvider)
        chatClient = AppDelegate.chatClientInstance()
        locationController = LocationController()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.bt_colorWithBytesR(133, g: 186, b: 255)]
        
        super.init()
        
        userDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfile.CurrentUserDidChangeNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                let newProfile = notification.object as? UserProfile
                self?.currentUserDidChange(newProfile)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(userDidChangeObserver)
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
    
    private class func chatClientInstance() -> XMPPClient {
        let appConfig = AppConfiguration()
        let chatConfig = XMPPClientConfiguration(with: appConfig.xmppHostname, port: appConfig.xmppPort)
        return XMPPClient(configuration: chatConfig)
    }
    
    func currentUserDidChange(profile: UserProfile?) {
        if  let user = profile,
            let chatCredentials = self.api.getChatCredentials() {
                chatClient.disconnect()
                chatClient = AppDelegate.chatClientInstance()
                chatClient.auth(chatCredentials.jid, password: chatCredentials.password).future().onSuccess { [unowned self] in
                    Log.info?.message("XMPP authorized")
                }.onFailure { error in
                    Log.error?.value(error)
                }
        } else {
            chatClient.disconnect()
        }
    }
    
    func setupMaps() {
        GMSServices.provideAPIKey(AppConfiguration().googleMapsKey)
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
    var chatClient: XMPPClient!
    synced(appDelegate) {
        chatClient = appDelegate.chatClient
    }
    return chatClient
}