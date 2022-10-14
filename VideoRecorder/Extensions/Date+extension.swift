//
//  Date+extension.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/14.
//

import Foundation

extension Date {
    func string(withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
