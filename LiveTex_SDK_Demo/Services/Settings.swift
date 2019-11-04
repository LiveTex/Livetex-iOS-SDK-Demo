//
//  Settings.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 02.11.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit

class Settings {

    private let userDefaults = UserDefaults.standard

    var key: String {
        get {
            return userDefaults.string(forKey: Key.key) ?? "demo"
        }
        set {
            userDefaults.set(newValue, forKey: Key.key)
        }
    }

    var siteID: String {
        get {
            return userDefaults.string(forKey: Key.siteID) ?? "123280"
        }
        set {
            userDefaults.set(newValue, forKey: Key.siteID)
        }
    }

    var path: String {
        get {
            return userDefaults.string(forKey: Key.path) ?? "https://authentication-service-sdk-production-1.livetex.ru"
        }
        set {
            userDefaults.set(newValue, forKey: Key.path)
        }
    }

    var visitor: String? {
        get {
            return userDefaults.string(forKey: Key.visitor)
        }
        set {
            userDefaults.set(newValue, forKey: Key.visitor)
        }
    }

}

extension Settings {

    enum Key: CaseIterable {
        static let key = "com.livetex.demo.key"
        static let siteID = "com.livetex.demo.siteID"
        static let path = "com.livetex.demo.url"
        static let visitor = "com.livetex.demo.visitor"
    }

}
