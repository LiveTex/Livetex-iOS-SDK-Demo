//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation

var URL:String? = ""

var key:String? = ""

var siteId:String? = "" //"10009747"//"10011885"


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