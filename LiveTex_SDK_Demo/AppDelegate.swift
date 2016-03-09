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
    var reachabilityAlert:UIAlertController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityChanged:"), name: kReachabilityChangedNotification, object: nil)
        
        //self.registerDefaultsFromSettingsBundle();
        
        internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier();

        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings
        notificationSettings: UIUserNotificationSettings) {
            if !application.isRegisteredForRemoteNotifications() {
                NSNotificationCenter.defaultCenter().postNotificationName("LTApiManager_token_got", object: nil)
            }
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
    
    func registerDefaultsFromSettingsBundle() {
        // this function writes default settings as settings
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        
        let settingsBundle: NSString = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle")!
        if (settingsBundle.containsString("")) {
            NSLog("Could not find Settings.bundle")
            return
        }
        let settings = NSDictionary(contentsOfFile: settingsBundle.stringByAppendingPathComponent("Root.plist"))!
        let preferences = settings.objectForKey("PreferenceSpecifiers") as! NSArray
        var defaultsToRegister = [String: AnyObject](minimumCapacity: preferences.count)
        
        for prefSpecification in preferences {
            if (prefSpecification.objectForKey("Key") != nil) {
                let key = prefSpecification.objectForKey("Key")! as! String
                if !key.containsString("") {
                    let currentObject = defaults.objectForKey(key)
                    if currentObject == nil {
                        // not readable: set value from Settings.bundle
                        let objectToSet = prefSpecification.objectForKey("DefaultValue")
                        defaultsToRegister[key] = objectToSet!
                    }
                }
            }
        }
        defaults.registerDefaults(defaultsToRegister)
        defaults.synchronize()
    }
    
    func processReachability(curReach:Reachability) {
        let status:NetworkStatus = curReach.currentReachabilityStatus()
        if status == NetworkStatus.NotReachable {
            LTApiManager.sharedInstance.sdk?.stop()
            if LTApiManager.sharedInstance.isSessionOnlineOpen == true {
                reachabilityAlert = UIAlertController(title: "", message: "Интернет соединение потеряно, дождитесь когда система востановит соединение", preferredStyle: UIAlertControllerStyle.Alert)
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