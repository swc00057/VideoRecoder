//
//  CMTime+extension.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/14.
//

import AVKit

extension CMTime {
    var durationText: String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
