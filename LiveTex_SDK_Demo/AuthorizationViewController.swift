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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(AuthorizationViewController.applicationDidRegisterWithDeviceToken), name: NSNotification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.registerForRemoteNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func applicationDidRegisterWithDeviceToken() {
        onlineModeButton.isEnabled = true
        startService()
    }
    
    func registerForRemoteNotifications() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: UIUserNotificationType([.alert, .sound]), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func startService() {
        print("startService URL \(URL!) siteID \(siteID!) key \(key!)")
        LivetexCoreManager.defaultManager.coreService = LCCoreService(url: URL!,
                                                                      appID: siteID!,
                                                                      appKey: key!,
                                                                      token: nil,
                                                                      deviceToken: LivetexCoreManager.defaultManager.apnToken,
                                                                      callbackQueue: OperationQueue.main,
                                                                      delegateQueue: OperationQueue.main)
        
        LivetexCoreManager.defaultManager.coreService.start { (token: String?, error: Error?) in
            if let error = error as? NSError {
                print(error)
                self.onlineModeButton.isEnabled = false
            } else {
                print(token!)
            }
        }
    }
    
    @IBAction func startConversation(sender: AnyObject) {
        if UserDefaults.standard.object(forKey: kLivetexVisitorName) != nil {
            self.navigationController?.show(ChatViewController(), sender: nil)
        } else {
            self.performSegue(withIdentifier: "conversation", sender: nil)
        }
    }
}
