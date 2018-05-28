//
//  DateUtil.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/27.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class DateUtil: NSObject {
    
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    init(format: String) {
        super.init()
        dateFormatter.dateFormat = format
    }
    
    static func convertToDate(_ timeStamp: UInt, format: String) -> String {
        let timeInterval: TimeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        let time = dateformatter.string(from: date)
        return time
    }
}
