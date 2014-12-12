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
    
    var internetReachability:Reachability!
    var reachabilityAlert:UIAlertView?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityChanged:"), name: kReachabilityChangedNotification, object: nil)
            
        internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier();
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        

    }
    
    func reachabilityChanged(note:NSNotification) {
        
        var curReach:Reachability = note.object as Reachability
        processReachability(curReach)
    }
    
    func processReachability(curReach:Reachability) {
        
        let status:NetworkStatus = curReach.currentReachabilityStatus()
        
        if status == NetworkStatus.NotReachable {
            
            LTApiManager.sharedInstance.sdk?.stop()
            
            if LTApiManager.sharedInstance.isSessionOpen == true {
                
                reachabilityAlert = UIAlertView(title: nil,
                    message: "Интернет соединение потеряно, дождитесь когда система востановит соединение",
                    delegate: nil,
                    cancelButtonTitle: "Ok")
                
                reachabilityAlert?.show()
            }
            
        } else {
            
            reachabilityAlert?.dismissWithClickedButtonIndex(0, animated: true)
            self.processSDKState()
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LTApiManager.sharedInstance.sdk?.stop()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        if internetReachability.currentReachabilityStatus() != NetworkStatus.NotReachable {
                  self.processSDKState()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {
        LTApiManager.sharedInstance.isSessionOpen = false
    }
    
    var isResumingSDKWorkFlow = false
    
    func processSDKState() {
        
        if isResumingSDKWorkFlow == true {return}
        
        println("-----------------------processSDKState------------------")
        isResumingSDKWorkFlow = true
        
        if LTApiManager.sharedInstance.isSessionOpen? == true {
            
            let initParam  = LTMobileSDKInitializationParams()
            initParam.sdkKey = "dev_key_test"
            initParam.livetexUrl = "http://192.168.78.14:10010"
            initParam.applicationId = LTApiManager.sharedInstance.aplicationId
            
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
        }
    }
    
    func processDialogState(state:LTSDialogState) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if state.conversationIsSet() {
            
            let rootController = storyboard.instantiateViewControllerWithIdentifier("ChatVC") as UIViewController
            
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
            
        } else if LTApiManager.sharedInstance.employeeId != nil {
            
            LTApiManager.sharedInstance.sdk!.requestWithEmployee(LTApiManager.sharedInstance.employeeId,
                success: { (dilogState:LTSDialogState!) -> Void in
                    
                let rootController = storyboard.instantiateViewControllerWithIdentifier("ChatVC") as UIViewController
                
                if self.window != nil {
                    self.window!.rootViewController = rootController
                }
                    
            }, failure: { (error:NSException!) -> Void in
                    
                let rootController = storyboard.instantiateViewControllerWithIdentifier("EnvolvingVC") as UIViewController
                
                if self.window != nil {
                    self.window!.rootViewController = rootController
                }
            })
            
        } else {
            
            let rootController = storyboard.instantiateViewControllerWithIdentifier("EnvolvingVC") as UIViewController
            
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
        }
    }
}

