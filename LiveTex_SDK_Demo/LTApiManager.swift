//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation

var URL:String? = "http://authentication-service-sdk-production-1.livetex.ru"
var key:String? = "demo"
var siteId:String? = "93438"
var offlineDeparmentId:String? = ""

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