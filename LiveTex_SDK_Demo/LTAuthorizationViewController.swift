//
//  ViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 05/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit


class LTAuthorizationViewController: UIViewController {
    
    @IBOutlet weak var applicationIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clean(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kLivetexPersistStorage)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func applicationIdConfirm(sender: AnyObject) {
        
        let initParam  = LTMobileSDKInitializationParams()
        //initParam.token = "token1"
        initParam.sdkKey = "dev_key_test"
        initParam.applicationId = applicationIdField.text
        initParam.livetexUrl = "http://192.168.78.14:10010"
        
        LTApiManager.sharedInstance.sdk = LTMobileSDK(params: initParam)
        
        var view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
        
        LTApiManager.sharedInstance.sdk!.runWithSuccess({ (token:String!) -> Void in
            
            LTApiManager.sharedInstance.aplicationId = self.applicationIdField.text
            LTApiManager.sharedInstance.isSessionOpen = true
            view.animateRemove()
            println(token)
            self.performSegueWithIdentifier("showEnvolving", sender: nil)
            
        }, failure: { (error:NSException!) -> Void in
            
            view.animateRemove()
            
            let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
            alert.show()
            println(error.description)
        })
    }
}

