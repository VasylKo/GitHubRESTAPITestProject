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
import FBSDKCoreKit
import XLForm
import Braintree
import Fabric
import Crashlytics

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
        Log.enable(.Verbose, synchronousMode: true)
        #else
        Log.enable(.Info, synchronousMode: false)
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
        chatClient = XMPPClient()
        locationController = LocationController()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.bt_colorWithBytesR(254, g: 187, b: 182)]
        UINavigationBar.appearance().barTintColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46)
        
        super.init()
        
        userDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfile.CurrentUserDidChangeNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                let newProfile = notification.object as? UserProfile
                self?.currentUserDidChange(newProfile)
        }
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
        
        // [START tracker_swift]
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = AppConfiguration().googleAnalystLogLevel
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeDonate] =
        "DonateCell"
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeMoreInformation] =
        "MoreInformationCell"
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeTotal] =
        "TotalCell"
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeMarketPaymentView] =
        "MarketPaymentView"

        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeError] =
        "ErrorCell"
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypePayment] =
        "PaymentTableViewCell"
        
        BTAppSwitch.setReturnURLScheme("\(NSBundle.mainBundle().bundleIdentifier!).payments")

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound],
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        Fabric.with([Crashlytics.self])
        
        NewRelic.startWithApplicationToken(AppConfiguration().newRelicToken);

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme.localizedCaseInsensitiveCompare("\(NSBundle.mainBundle().bundleIdentifier!).payments") == .OrderedSame {
            return BTAppSwitch.handleOpenURL(url, sourceApplication:sourceApplication)
        }

        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url,
            sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = (deviceToken.description as NSString)
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        api.setDeviceToken(deviceTokenString)
        api.pushesRegistration()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //TODO handle
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        showSuccess("receive push note")
    }
}

extension AppDelegate {
    
    private class func chatClientInstance() -> XMPPClient {
        let appConfig = AppConfiguration()
        let chatConfig = XMPPClientConfiguration(with: appConfig.xmppHostname, port: appConfig.xmppPort)
        let credentialsProvider = appDelegate().api.chatCredentialsProvider()
        return XMPPClient(configuration: chatConfig, credentialsProvider: credentialsProvider)
    }
    
    func currentUserDidChange(profile: UserProfile?) {
        chatClient.disconnect()
        if let user = profile {
            let conversationManager = ConversationManager.sharedInstance()
            conversationManager.updateUserId(user.objectId)
            chatClient = AppDelegate.chatClientInstance()
            chatClient.delegate = conversationManager
            chatClient.auth()
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
                showWarning(error.localizedDescription)
            default:
                //TODO: remove hot fix
                if error.localizedDescription != "Invalid_token" {
                    showWarning(error.localizedDescription)
                }
            }
        }
    }
}

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

func api() -> APIService {
    return appDelegate().api
}

func locationController() -> LocationController {
    return appDelegate().locationController
}

func chat() -> XMPPClient {
    let applicationDelegate = appDelegate()
    var chatClient: XMPPClient!
    synced(applicationDelegate) {
        chatClient = applicationDelegate.chatClient
    }
    return chatClient
}