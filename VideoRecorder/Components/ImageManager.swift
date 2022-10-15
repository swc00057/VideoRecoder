//
//  ImageManager.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/12.
//
import UIKit
import Photos

class ImageManager {

    static let shared = ImageManager()
    
    private let imageManager: PHImageManager

    private init() {
        imageManager = PHImageManager()
    }
    
    func requestImage(from asset: PHAsset, thumnailSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        self.imageManager.requestImage(for: asset, targetSize: thumnailSize, contentMode: .aspectFill, options: nil) { image, info in
            completion(image)
        }
    }

}
