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

struct TestAPI: APIService {
    func http(endpoint: String) -> String {
        return ""
    }
    func https(endpoint: String) -> String {
        return "https://api-qa.gwynniebee.com:4443/v1/closets/users/74e17682-e13c-3fb1-b439-98105d69eb79/active/count.json?store_id=1&list_state_ids=2"
    }
    
    var description: String {
        return "TestAPI"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataProvider = NetworkDataProvider(api: TestAPI())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let mapping: AnyObject? -> Int? = { json in
            let dict = json as? NSDictionary
            let number = dict?["count_active_closet"] as? NSNumber
            return number?.integerValue
        }

        let url = NSURL(string: dataProvider.apiService.https(""))
        let request = NSURLRequest(URL: url!)

        
        let completion: (OperationResult<Int>)->Void = { result in
            switch result {
            case .Failure(let error):
                println(error)
            case .Success(_):
                println("Success: got \(result.value)")
            }
        }
        
        dataProvider.jsonRequest(request, map: mapping, completion: completion)


        presentRootController()
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
    
    private func presentRootController() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let centerController = UINavigationController(rootViewController: Storyboards.Main.instantiateMapViewController())
        let sidebarController = Storyboards.Main.instantiateMainMenuViewController()
        window?.rootViewController = SidebarViewController(centerViewController:
            centerController, andSidebarViewController: sidebarController)
        window?.makeKeyAndVisible()
    }

}

