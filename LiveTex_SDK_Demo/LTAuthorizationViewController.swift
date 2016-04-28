//
//  ViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTAuthorizationViewController: UIViewController {
    @IBOutlet weak var suggetionLabel: UILabel!
    @IBOutlet weak var onlineModeButton: UIButton!
    @IBOutlet weak var offlineModeButton: UIButton!
    
    var dialogState:LTSDialogState?
    var activityView:DejalBezelActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LTAuthorizationViewController.gotToken), name: "LTApiManager_token_got", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.registerForRemoteNotifications()
    }
    
    func registerForRemoteNotifications() {
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType([.Alert, .Sound]), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
}

//MARK: business Flow

extension LTAuthorizationViewController {
    func startWelcome() {
        let initParam  = LTMobileSDKInitializationParams()
        initParam.sdkKey = key
        initParam.livetexUrl = URL
        initParam.applicationId = siteID
        initParam.APNDeviceId = LTApiManager.sharedInstance.apnToken
        initParam.capabilities = [0,5,6,7]
        
        LTApiManager.sharedInstance.sdk = LTMobileSDK(params: initParam)
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.runWithSuccess({ (token:String!) -> Void in
            print(token)
            self.processOnlineConversationState()
            self.processOnlineConversationAbility()
        }, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }
    
    func processOnlineConversationState() {
        LTApiManager.sharedInstance.sdk?.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            self.dialogState = state
            if self.dialogState?.conversation != nil {
                self.performSegueWithIdentifier("show_chat", sender: nil)
            }
        }, failure: { (exp:NSException!) -> Void in
            self.loadingErrorProcess(exp)
        })
    }

    func processOnlineConversationAbility() {
        LTApiManager.sharedInstance.sdk!.getDepartments(statusType.online, success: { (items:[AnyObject]!) -> Void in
            self.removeActivityIndicator()
            if (items.count == 0) {
                self.onlineModeButton.enabled = false
                self.onlineModeButton.imageView?.image = UIImage(contentsOfFile: "button_offline.png");
            }
        }, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }
}

//MARK: notification listener selectors

extension LTAuthorizationViewController {
    func gotToken () {
        onlineModeButton.enabled = true
        offlineModeButton.enabled = true
        
        startWelcome()
    }
}

//MARK: target - Action

extension LTAuthorizationViewController {
    @IBAction func startOnlineMode(sender:AnyObject) {
        LTApiManager.sharedInstance.isSessionOnlineOpen = true
        if dialogState?.conversation != nil {
            self.performSegueWithIdentifier("show_chat", sender: nil)
        } else {
            self.performSegueWithIdentifier("showConversation", sender: nil)
        }
    }
    
    @IBAction func startOfflineMode(sender:AnyObject) {
        self.performSegueWithIdentifier("showOffline", sender: nil)
    }
    
    @IBAction func unwind(segue:UIStoryboardSegue) {}
}

//MARK: helpers

extension LTAuthorizationViewController {
    func showActivityIndicator() {
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        self.removeActivityIndicator()
        let alert: UIAlertController = UIAlertController(title: "Ошибка", message: (error.userInfo!["error"] as! NSError).localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

