//
//  ViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore

let kApplicationDidReceiveNetworkStatus = "kApplicationDidReceiveNetworkStatus"
let kApplicationDidRegisterWithDeviceToken = "kApplicationDidRegisterWithDeviceToken"

class AuthorizationViewController: UIViewController {
    @IBOutlet weak var onlineModeButton: UIButton!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AuthorizationViewController.applicationDidRegisterWithDeviceToken), name: kApplicationDidRegisterWithDeviceToken, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.registerForRemoteNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func applicationDidRegisterWithDeviceToken() {
        onlineModeButton.enabled = true
        
        startService()
    }
    
    func registerForRemoteNotifications() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType([.Alert, .Sound]), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func startService() {
        LivetexCoreManager.defaultManager.coreService = LCCoreService(URL: URL!,
                                                                      appID: siteID!,
                                                                      appKey: key!,
                                                                      token: nil,
                                                                      deviceToken: LivetexCoreManager.defaultManager.apnToken,
                                                                      callbackQueue: NSOperationQueue.mainQueue(),
                                                                      delegateQueue: NSOperationQueue.mainQueue())
        
        LivetexCoreManager.defaultManager.coreService.startServiceWithCompletionHandler { (token: String?, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
                self.onlineModeButton.enabled = false
            } else {
                print(token!)
            }
        }
    }
    
    @IBAction func startConversation(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(kLivetexVisitorName) != nil {
            self.navigationController?.showViewController(ChatViewController(), sender: nil)
        } else {
            self.performSegueWithIdentifier("conversation", sender: nil)
        }
    }
}