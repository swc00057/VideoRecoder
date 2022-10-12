//
//  Video.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/12.
//

import UIKit

struct Video {
    let title: String
    let thumbnail: UIImage
    let date: String
    let duration: String
}

extension Video {
    static var sampleData: [Video] = [
        Video(title: "Nature.mp4", thumbnail: UIImage(named: "Nature")!, date: "2022-09-22", duration: "3:21"),
        Video(title: "Food.mp4", thumbnail: UIImage(named: "Food")!, date: "2022-09-17", duration: "15:50"),
        Video(title: "Building.mp4", thumbnail: UIImage(named: "Building")!, date: "2022-09-04", duration: "0:21"),
        Video(title: "Concert.mp4", thumbnail: UIImage(named: "Concert")!, date: "2022-08-05", duration: "1:13:27"),
        Video(title: "Bridge.mp4", thumbnail: UIImage(named: "Bridge")!, date: "2022-07-21", duration: "32:03"),
        
    ]
}
