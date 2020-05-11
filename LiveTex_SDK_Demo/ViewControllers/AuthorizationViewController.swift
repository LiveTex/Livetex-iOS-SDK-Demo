//
//  ViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore

class AuthorizationViewController: UIViewController {

    @IBOutlet private weak var onlineModeButton: UIButton!

    private let settings = Settings()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidRegisterWithDeviceToken),
                                               name: .applicationDidRegisterWithDeviceToken,
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
        Livetex.shared.coreService = LCCoreService(url: settings.path,
                                                   appID: settings.siteID,
                                                   appKey: settings.key,
                                                   token: nil,
                                                   deviceToken: Livetex.shared.apnToken,
                                                   callbackQueue: .main,
                                                   delegateQueue: .main)

        Livetex.shared.coreService.start { token, error in
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
        if settings.visitor != nil {
            navigationController?.show(ChatViewController(), sender: nil)
        } else {
            performSegue(withIdentifier: "conversation", sender: nil)
        }
    }
}
