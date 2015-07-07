//
//  ViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTAuthorizationViewController: UIViewController {
    
    var activityView:DejalBezelActivityView?
    
    @IBOutlet weak var suggetionLabel: UILabel!
    @IBOutlet weak var onlineModeButton: UIButton!
    @IBOutlet weak var offlineModeButton: UIButton!
    
    var dialogState:LTSDialogState?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        commonPreparations()
    }
    
    func commonPreparations() {
        
        if LTApiManager.sharedInstance.apnToken == nil {
            
            onlineModeButton.enabled = false
            offlineModeButton.enabled = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotToken", name: "LTApiManager_token_got", object: nil)
            
        } else {
            startWelcome()
        }
    }
}

//MARK: business Flow

extension LTAuthorizationViewController {
    
    func clean() {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kLivetexPersistStorage)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func startWelcome() {
        
        let initParam  = LTMobileSDKInitializationParams()
        initParam.sdkKey = key
        initParam.livetexUrl = URL
        initParam.applicationId = siteId
        initParam.APNDeviceId = LTApiManager.sharedInstance.apnToken
        
        LTApiManager.sharedInstance.sdk = LTMobileSDK(params: initParam)
        
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.runWithSuccess({ (token:String!) -> Void in
            
            println(token)
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
        
        LTApiManager.sharedInstance.sdk!.getEmployees(statusType.online, success: { (items:[AnyObject]!) -> Void in
            
            self.removeActivityIndicator()
            
            if (items.count == 0) {
                self.suggetionLabel.text = "В данный момент нет операторов онлайн, возможен только режим оффлайн обращения"
                self.onlineModeButton.enabled = false
            } else {
                self.suggetionLabel.text =  " "
            }
            
        }, failure:{ (error:NSException!) -> Void in
                
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
            self.performSegueWithIdentifier("showEnvolving", sender: nil)
        }
    }
    
    @IBAction func startOfflineMode(sender:AnyObject) {
        
        self.performSegueWithIdentifier("showOffline", sender: nil)
    }
    
    @IBAction func unwind(segue:UIStoryboardSegue) {
        
    }
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
        let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
}

