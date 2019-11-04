//
//  NSNotification+Factory.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 02.11.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit

extension NSNotification.Name {

    static let applicationDidRegisterWithDeviceToken = NSNotification.Name(rawValue: "kApplicationDidRegisterWithDeviceToken")
    static let applicationDidReceiveNetworkStatus = NSNotification.Name(rawValue: "kApplicationDidReceiveNetworkStatus")

}
