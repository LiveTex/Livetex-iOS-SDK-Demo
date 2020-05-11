//
//  File.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import LivetexCore

class Livetex {
    static let shared: Livetex = Livetex()
    
    var coreService: LCCoreService!
    var apnToken: String?
}
