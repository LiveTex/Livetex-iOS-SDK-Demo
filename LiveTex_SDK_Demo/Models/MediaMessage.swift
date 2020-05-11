//
//  MediaMessage.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 26.10.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit
import MessageKit

struct MediaMessage: MediaItem {

    let url: URL?
    let image: UIImage?
    let placeholderImage: UIImage
    let size: CGSize

    // MARK: - Initialization

    init(image: UIImage?) {
        url = nil
        self.image = image
        placeholderImage = UIImage(color: .lightGray) ?? UIImage()
        size = CGSize(width: 240, height: 240)
    }

    init(url: URL?) {
        self.url = url
        image = nil
        placeholderImage = UIImage(color: .lightGray) ?? UIImage()
        size = CGSize(width: 240, height: 240)
    }

}
