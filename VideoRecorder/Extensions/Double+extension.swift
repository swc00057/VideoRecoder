//
//  Double+extension.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/13.
//

import Foundation

extension Double {
    func format() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        return formatter.string(from: self)!
    }
}
