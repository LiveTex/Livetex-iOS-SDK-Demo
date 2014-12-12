//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation


class LTApiManager {
    
    var sdk: LTMobileSDK?
    
    var aplicationId: String?
    
    var isSessionOpen:Bool?
    
    var employeeId: LTSEmployeeId?
    
    class var sharedInstance : LTApiManager {
        struct Static {
            static let instance : LTApiManager = LTApiManager()
        }
        return Static.instance
    }
}