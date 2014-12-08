//
//  LTSDKNotificationLogsViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 04/12/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTSDKNotificationLogsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

         textView.text = LTApiManager.sharedInstance.sdk?.getNotificationLogs()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
