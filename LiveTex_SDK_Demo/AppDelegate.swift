//
//  AppDelegate.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import Fabric
import CoreData
import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var internetReachability: Reachability!
    var reachabilityAlert: UIAlertController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        internetReachability = Reachability.forInternetConnection()
        internetReachability.startNotifier();
        Fabric.with([Crashlytics.self])

        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if !application.isRegisteredForRemoteNotifications {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token registration: \(tokenString)")
        LivetexCoreManager.defaultManager.apnToken = tokenString as String
        NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("token registration failed: \(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
    }
    
    @objc func reachabilityChanged(_ note:Notification) {
        let curReach: Reachability = note.object as! Reachability
        processReachability(curReach)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func processReachability(_ curReach: Reachability) {
        let status:NetworkStatus = curReach.currentReachabilityStatus()
        if status == NetworkStatus.NotReachable {
            reachabilityAlert = UIAlertController(title: "", message: "Интернет соединение потеряно, дождитесь когда система восстановит соединение", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            reachabilityAlert!.addAction(cancelAction)
            self.window?.rootViewController?.present(reachabilityAlert!, animated: true, completion: nil)
        } else {
            reachabilityAlert?.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidReceiveNetworkStatus), object: NSNumber(value: status.rawValue as UInt))
    }
}
