//
//  TimeInterval+extension.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/13.
//

import Foundation

extension TimeInterval {
    public var displayTime: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        if self < 60 * 60 {
            formatter.allowedUnits = [.minute, .second]
        } else {
            formatter.allowedUnits = [.hour, .minute, .second]
        }
        return formatter.string(from: self) ?? nil
    }
}
