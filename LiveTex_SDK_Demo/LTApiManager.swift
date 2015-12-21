//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
/*
var URL:String? = "http://authentication-service-sdk-production-1.livetex.ru" //"http://authentication-service.livetex.omnitest:80/" //"http://authentication-service-sdk-production-1.livetex.ru"//"http://authentication-service.livetex.omnitest:80/" //"http://authentication-service-sdk-production-1.livetex.ru"  //"http://authentication-service-sdk-prerelease.livetex.ru" //"http://authentication-service.livetex.omnibuild:80/" //"http://authentication-service-sdk-production-1.livetex.ru"
var key:String? =  "demo" //"mgvoronin.sbt@sberbank.ru" //"demo" //"dev_key_test" //"demo" // "dev_key_test" //"demo" //"prerelease_key" //"dev_key_test" //"demo"
var siteId:String? = "111219" //"49134" //"106217"//"106204" //"106217" //"10009775" //"98527" //"10009747" //"106217" //"98527" //"92941" //"10009747" //99878 //98527 Юра
var offlineDeparmentId:String? = "119425" //"72879" //"42" //"10246" //"42" //"117168" //"42" // 12448 // "10246"
*/

var URL: String? = NSUserDefaults.standardUserDefaults().stringForKey("LivetexURL")
var key: String? = NSUserDefaults.standardUserDefaults().stringForKey("LivetexKey")
var siteID: String? = NSUserDefaults.standardUserDefaults().stringForKey("LivetexSiteID")
var offlineDepID: String? = NSUserDefaults.standardUserDefaults().stringForKey("LivetexDepID")

class LTApiManager {
    
    var sdk: LTMobileSDK?
    var apnToken: String?
    var isSessionOnlineOpen:Bool?
    var onlineEmployeeId: LTSEmployeeId?
    var offlineConversationId: String?
    
    class var sharedInstance : LTApiManager {
        
        struct Static {
            
            static let instance : LTApiManager = LTApiManager()
        }
        
        return Static.instance
    }
}