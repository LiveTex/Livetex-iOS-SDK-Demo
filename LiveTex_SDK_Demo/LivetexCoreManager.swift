//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import LivetexCore

var URL:String? = "https://authentication-service-sdk-production-1.livetex.ru"
var key:String? =  "demo"
var siteID:String? = "123280"

class LivetexCoreManager {
    static let defaultManager: LivetexCoreManager = LivetexCoreManager()
    
    var coreService: LCCoreService!
    var apnToken: String?
}
