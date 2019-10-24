//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import LivetexCore

var url = "https://authentication-service-sdk-production-1.livetex.ru"
var key = "demo"
var siteID = "123280"

class LivetexCoreManager {
    static let defaultManager: LivetexCoreManager = LivetexCoreManager()
    
    var coreService: LCCoreService!
    var apnToken: String?
}
