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
        
        if SYSTEM_VERSION_LESS_THAN("8.0.0") {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        } else {
           let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert, categories: nil)
            application .registerUserNotificationSettings(settings)
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings
        notificationSettings: UIUserNotificationSettings) {
            
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = NSMutableString()
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString.appendFormat("%02.2hhx", tokenChars[i])
        }
        
        LTApiManager.sharedInstance.apnToken = tokenString as String
        
        println("tokenString: \(tokenString)")
    }
    
    func reachabilityChanged(note:NSNotification) {
        
        var curReach:Reachability = note.object as! Reachability
        processReachability(curReach)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LTApiManager.sharedInstance.sdk?.stop()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        if internetReachability.currentReachabilityStatus() != NetworkStatus.NotReachable {
            self.processSDKState()
        }
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
            self.processSDKState()
        }
    }
    
    var isResumingSDKWorkFlow = false
    
    func processSDKState() {
        
        if isResumingSDKWorkFlow == true {return}
        
        println("-----------------------processSDKState------------------")
        isResumingSDKWorkFlow = true
        
        if LTApiManager.sharedInstance.isSessionOnlineOpen == true {
            
            println("-----------------------initSDK------------------")
            let initParam  = LTMobileSDKInitializationParams()
            initParam.sdkKey = key
            initParam.livetexUrl = URL
            initParam.applicationId = siteId
            initParam.APNDeviceId = LTApiManager.sharedInstance.apnToken
            
            LTApiManager.sharedInstance.sdk = LTMobileSDK(params: initParam)
            
            var view = DejalBezelActivityView(forView: window, withLabel: "Загрузка", width:100)
            
            LTApiManager.sharedInstance.sdk!.runWithSuccess({ (token:String!) -> Void in
                
                LTApiManager.sharedInstance.sdk!.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
                    
                    view.animateRemove()
                    self.processDialogState(state)
                    self.isResumingSDKWorkFlow = false
                    
                }, failure: { (error:NSException!) -> Void in
                        
                    view.animateRemove()
                    
                    let alert: UIAlertView = UIAlertView(title: "ошибка",
                        message: error.description,
                        delegate: nil,
                        cancelButtonTitle: "ОК")
                    
                    alert.show()
                    self.isResumingSDKWorkFlow = false
                })

            }, failure: { (error:NSException!) -> Void in
                    
                view.animateRemove()
                
                let alert: UIAlertView = UIAlertView(title: "ошибка",
                    message: error.description,
                    delegate: nil,
                    cancelButtonTitle: "ОК")
                
                alert.show()
                println(error.description)
                self.isResumingSDKWorkFlow = false
            })
            
        } else {
            isResumingSDKWorkFlow = false
        }
    }
    
    func processDialogState(state:LTSDialogState) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if state.conversationIsSet() {
            
            let rootController = storyboard.instantiateViewControllerWithIdentifier("ChatVC") as! UIViewController
            
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
            
        } else if LTApiManager.sharedInstance.onlineEmployeeId != nil {
            
            LTApiManager.sharedInstance.sdk!.requestWithEmployee(LTApiManager.sharedInstance.onlineEmployeeId as! String,
                success: { (dilogState:LTSDialogState!) -> Void in
                    
                let rootController = storyboard.instantiateViewControllerWithIdentifier("ChatVC") as! UIViewController
                
                if self.window != nil {
                    self.window!.rootViewController = rootController
                }
                    
            }, failure: { (error:NSException!) -> Void in
                    
                let rootController = storyboard.instantiateViewControllerWithIdentifier("EnvolvingVC") as! UIViewController
                
                if self.window != nil {
                    self.window!.rootViewController = rootController
                }
            })
            
        } else {
            
            let rootController = storyboard.instantiateViewControllerWithIdentifier("EnvolvingVC") as! UIViewController
            
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
        }
    }
}

