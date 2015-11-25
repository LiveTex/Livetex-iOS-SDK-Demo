//
//  CommonUtils.swift
//  LiveTex SDK
//
//  Created by Сергей Девяткин on 10/1/15.
//  Copyright © 2015 LiveTex. All rights reserved.
//

import Foundation

class CommonUtils {
    
    static func showAlert(str: String) -> Void {
        UIAlertView(title: "", message: str, delegate: nil, cancelButtonTitle: "ОК").show()
    }
    
    static func isWhiteSpaceString(str:String) -> Bool {
        
        (str as NSString).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if str == "" {
            return true
        }
        else {
            return false
        }
    }
    
    static func isValidPhone(str: String) -> Bool {
        if((str as NSString).length < 7 || (str as NSString).length > 20 || !checkIfNumber(str)) {
            return false
        }
        return true
    }
    
    static func showToast(message: String) {
        let toast: UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
        toast.show()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            toast.dismissWithClickedButtonIndex(0, animated: true)
        }
        
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluateWithObject(testStr)
        
        return result
        
    }

    
    private static func checkIfNumber(str: String) -> Bool {
        let num: UInt64? = UInt64(str)
        if(num != nil) {
            return true
        } else {
            return false
        }
    }

}