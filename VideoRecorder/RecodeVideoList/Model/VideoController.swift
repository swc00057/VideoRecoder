//
//  VideoController.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/12.
//

import UIKit

class VideoController {
    private var videos: [Video] = [
        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "Bridge.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),

        Video(title: "NatureNatureNatureNatureNatureNatureNatureNatureNatureNatureNatureNatureNature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "ConcertConcertConcertConcertConcertConcertConcertConcertConcertConcertConcert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "BridgeBridgeBridgeBridgeBridgeBridgeBridgeBridgeBridgeBridgeBridge.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),

        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "15.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),

        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "20.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),

        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "25.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),

        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "30.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),
    ]

    private var fetchLimit = 0
    private let fetchSize = 6

    func fetch(completion: (([Video]) -> Void)? = nil) {
        fetchLimit += fetchSize
        let videos = videos.prefix(fetchLimit)
        completion?(Array(videos))
    }

}
