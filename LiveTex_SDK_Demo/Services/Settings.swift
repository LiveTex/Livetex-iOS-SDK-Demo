//
//  Settings.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 02.11.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit

final class Settings {

    @UserDefault(key: Key.key, defaultValue: "demo")
    var key: String

    @UserDefault(key: Key.siteID, defaultValue: "123280")
    var siteID: String

    @UserDefault(key: Key.path, defaultValue: "https://authentication-service-sdk-production-1.livetex.ru")
    var path: String

    @UserDefault(key: Key.visitor, defaultValue: "")
    var visitor: String

}

extension Settings {

    enum Key: CaseIterable {
        static let key = "com.livetex.demo.key"
        static let siteID = "com.livetex.demo.siteID"
        static let path = "com.livetex.demo.url"
        static let visitor = "com.livetex.demo.visitor"
    }

}
