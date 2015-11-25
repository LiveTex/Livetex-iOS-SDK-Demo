//
//  AppDelegate.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import CoreData

func SYSTEM_VERSION_LESS_THAN(v:String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(v, options: NSStringCompareOptions.NumericSearch) == .OrderedAscending
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var internetReachability:Reachability!
    var reachabilityAlert:UIAlertView?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityChanged:"), name: kReachabilityChangedNotification, object: nil)

        internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier();
        
//        if SYSTEM_VERSION_LESS_THAN("8.0") {
//            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
//        } else {
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: /*UIUserNotificationType.Sound | */UIUserNotificationType.Alert, categories: nil)
            application .registerUserNotificationSettings(settings)
      //  }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings
        notificationSettings: UIUserNotificationSettings) {
            
            application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
            
            let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
            let tokenString = NSMutableString()
            
            for var i = 0; i < deviceToken.length; i++ {
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
        let curReach:Reachability = note.object as! Reachability
        processReachability(curReach)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        LTApiManager.sharedInstance.isSessionOnlineOpen = false
    }
    
    func processReachability(curReach:Reachability) {
        
        let status:NetworkStatus = curReach.currentReachabilityStatus()
        
        if status == NetworkStatus.NotReachable {
            
            LTApiManager.sharedInstance.sdk?.stop()
            
            if LTApiManager.sharedInstance.isSessionOnlineOpen == true {
                
                reachabilityAlert = UIAlertView(title: nil,
                    message: "Интернет соединение потеряно, дождитесь когда система востановит соединение",
                    delegate: nil,
                    cancelButtonTitle: "Ok")
                
                LTApiManager.sharedInstance.sdk?.delegate?.updateDialogState(LTSDialogState(conversation: nil, employee: nil))
                
                reachabilityAlert?.show()
            }
            
        } else {
            
            reachabilityAlert?.dismissWithClickedButtonIndex(0, animated: true)
        }
    }
}

