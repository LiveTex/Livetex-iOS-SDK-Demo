//
//  UserDefault.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 24.02.2020.
//  Copyright © 2020 LiveTex. All rights reserved.
//

import UIKit

@propertyWrapper
struct UserDefault<T> {

    private let key: String
    private let defaultValue: T

    // MARK: - Initialization

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
