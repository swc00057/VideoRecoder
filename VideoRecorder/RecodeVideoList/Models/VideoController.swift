//
//  VideoController.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/12.
//

import UIKit

class VideoController {
    static let shared = VideoController()

    private var videos: [Video]

    private var fetchLimit = 0
    private let fetchSize = 6

    var count: Int {
        min(videos.count, fetchLimit)
    }

    private init() {
        videos = VideoController.load("Video.json")
    }

    private static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }

    func fetch(completion: (() -> Void)? = nil) {
        fetchLimit += fetchSize
        completion?()
    }

    func video(at index: Int) -> Video {
        return videos[index]
    }

}
