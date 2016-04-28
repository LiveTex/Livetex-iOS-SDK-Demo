//
//  AppDelegate.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var internetReachability: Reachability!
    var reachabilityAlert: UIAlertController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier();

        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if !application.isRegisteredForRemoteNotifications() {
            NSNotificationCenter.defaultCenter().postNotificationName("LTApiManager_token_got", object: nil)
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        let tokenString = NSMutableString()
        
        for i in 0 ..< deviceToken.length {
            tokenString.appendFormat("%02.2hhx", tokenChars[i])
        }
        
        LTApiManager.sharedInstance.apnToken = tokenString as String
        NSNotificationCenter.defaultCenter().postNotificationName("LTApiManager_token_got", object: nil)
        print("tokenString: \(tokenString)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName("LTApiManager_token_got", object: nil)
    }
    
    func reachabilityChanged(note:NSNotification) {
        let curReach: Reachability = note.object as! Reachability
        processReachability(curReach)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        LTApiManager.sharedInstance.isSessionOnlineOpen = false
    }
    
    func processReachability(curReach: Reachability) {
        let status:NetworkStatus = curReach.currentReachabilityStatus()
        if status == NetworkStatus.NotReachable {
            if LTApiManager.sharedInstance.isSessionOnlineOpen == true {
                reachabilityAlert = UIAlertController(title: "", message: "Интернет соединение потеряно, дождитесь когда система восстановит соединение", preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                reachabilityAlert!.addAction(cancelAction)
                self.window?.rootViewController?.presentViewController(reachabilityAlert!, animated: true, completion: nil)
            }
        } else {
            reachabilityAlert?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("LTNetworkNotification", object: NSNumber(unsignedInteger: status.rawValue))
    }
}