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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        startWelcome()
    }

    func clean() {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kLivetexPersistStorage)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func startWelcome() {
        
        clean()
        
        let initParam  = LTMobileSDKInitializationParams()
        initParam.sdkKey = key
        initParam.livetexUrl = URL
        initParam.applicationId = siteId
        initParam.APNDeviceId = LTApiManager.sharedInstance.apnToken
        
        LTApiManager.sharedInstance.sdk = LTMobileSDK(params: initParam)
        
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.runWithSuccess({ (token:String!) -> Void in
        
            println(token)
            LTApiManager.sharedInstance.sdk!.getEmployees(statusType.online, success: { (items:[AnyObject]!) -> Void in
                
                self.removeActivityIndicator()
                self.processAbility(items)
                
            }, failure:{ (error:NSException!) -> Void in
                
                self.loadingErrorProcess(error)
            })
            
        }, failure: { (error:NSException!) -> Void in
            
            self.loadingErrorProcess(error)
        })
    }
    
    func processAbility(items:[AnyObject]!) {
        
        if (items.count == 0) {
            suggetionLabel.text = "В данный момент нет операторов онлайн, возможен только режим оффлайн обращения"
            onlineModeButton.enabled = false
        } else {
            suggetionLabel.text =  ""
        }
    }
    
    @IBAction func startOnlineMode(sender:AnyObject) {
        
        LTApiManager.sharedInstance.isSessionOpen = true
        self.performSegueWithIdentifier("showEnvolving", sender: nil)
    }
    
    @IBAction func startOfflineMode(sender:AnyObject) {
        
        self.performSegueWithIdentifier("showEnvolving", sender: nil)
    }
}

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

