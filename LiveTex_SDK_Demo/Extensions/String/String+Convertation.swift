//
//  String+Convertation.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 16.11.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit

extension String {

    var doubleValue: Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }

}
