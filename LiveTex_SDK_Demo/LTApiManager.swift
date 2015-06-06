//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation

var URL:String? = "http://authentication-service.livetex.omnibuild:80/"

var key:String? = "dev_key_test"

var siteId:String? = "10011885"


class LTApiManager {
    
    var sdk: LTMobileSDK?
    var apnToken: String?
    var isSessionOpen:Bool?
    var employeeId: LTSEmployeeId?
    
    class var sharedInstance : LTApiManager {
        
        struct Static {
            
            static let instance : LTApiManager = LTApiManager()
        }
        return Static.instance
    }
}