//
//  Data+Hex.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 04.11.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit

extension Data {

    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }

}
