//
//  PhotoKit+.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/13.
//

import Photos

extension PHAsset {
    var primaryResource: PHAssetResource? {
        let types: Set<PHAssetResourceType>

        switch mediaType {
        case .video:
            types = [.video, .fullSizeVideo]
        case .image:
            types = [.photo, .fullSizePhoto]
        case .audio:
            types = [.audio]
        case .unknown:
            types = []
        @unknown default:
            types = []
        }

        let resources = PHAssetResource.assetResources(for: self)
        let resource = resources.first { types.contains($0.type) }

        return resource ?? resources.first
    }

    var originalFilename: String {
        guard let result = primaryResource else {
            return "file"
        }

        return result.originalFilename
    }
}
