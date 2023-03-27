//
//  PhotoMessage.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 19.03.2023.
//

import UIKit
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(filePath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
