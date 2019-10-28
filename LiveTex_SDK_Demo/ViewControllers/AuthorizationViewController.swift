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

    @IBOutlet private weak var onlineModeButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidRegisterWithDeviceToken),
                                               name: NSNotification.Name(rawValue: kApplicationDidRegisterWithDeviceToken),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForRemoteNotifications()
    }

    // MARK: - Notification

    @objc private func applicationDidRegisterWithDeviceToken() {
        onlineModeButton.isEnabled = true
        
        startService()
    }
    
    func registerForRemoteNotifications() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: UIUserNotificationType([.alert, .sound]), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func startService() {
        LivetexCoreManager.defaultManager.coreService = LCCoreService(url: url,
                                                                      appID: siteID,
                                                                      appKey: key,
                                                                      token: nil,
                                                                      deviceToken: LivetexCoreManager.defaultManager.apnToken,
                                                                      callbackQueue: .main,
                                                                      delegateQueue: .main)
        
        LivetexCoreManager.defaultManager.coreService.start { token, error in
            if let err = error {
                print(err)
                self.onlineModeButton.isEnabled = false
            } else {
                print(token)
            }
        }
    }

    // MARK: - Action
    
    @IBAction private func startConversation(sender: UIButton) {
        if UserDefaults.standard.object(forKey: kLivetexVisitorName) != nil {
            navigationController?.show(ChatViewController(), sender: nil)
        } else {
            performSegue(withIdentifier: "conversation", sender: nil)
        }
    }
}
