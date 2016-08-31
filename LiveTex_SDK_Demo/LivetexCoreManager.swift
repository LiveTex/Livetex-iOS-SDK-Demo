//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import LivetexCore

var URL:String? = "https://authentication-service-sdk-production-1.livetex.ru" //"http://authentication-service.livetex.omnitest:80/" //"http://authentication-service-sdk-production-1.livetex.ru"//"http://authentication-service.livetex.omnitest:80/" //"http://authentication-service-sdk-production-1.livetex.ru"  //"http://authentication-service-sdk-prerelease.livetex.ru" //"http://authentication-service.livetex.omnibuild:80/" //"http://authentication-service-sdk-production-1.livetex.ru"
var key:String? =  "demo" //"mgvoronin.sbt@sberbank.ru" //"demo" //"dev_key_test" //"demo" // "dev_key_test" //"demo" //"prerelease_key" //"dev_key_test" //"demo"
var siteID:String? = "106217" //"49134" //"106217"//"106204" //"106217" //"10009775" //"98527" //"10009747" //"106217" //"98527" //"92941" //"10009747" //99878 //98527 Юра

class LivetexCoreManager {
    static let defaultManager: LivetexCoreManager = LivetexCoreManager()
    
    var coreService: LCCoreService!
    var apnToken: String?
}