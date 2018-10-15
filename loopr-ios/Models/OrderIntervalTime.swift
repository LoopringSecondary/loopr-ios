//
//  ExpirationTimeSetting.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderIntervalTime: NSObject, NSCoding {

    var intervalValue: Int
    var intervalUnit: Calendar.Component
    
    init(intervalValue: Int, intervalUnit: Calendar.Component) {
        self.intervalValue = intervalValue
        self.intervalUnit = intervalUnit
    }
    
    override init() {
        intervalValue = 1
        intervalUnit = .hour
    }
    
    func encode(with aCoder: NSCoder) {
        if let unit = OrderIntervalTime.fromComponentToString(component: intervalUnit) {
            // Int value may raise errors.
            aCoder.encode(String(intervalValue), forKey: "intervalValue.stringValue")
            aCoder.encode(unit, forKey: "intervalUnit.stringValue")
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let intervalValueStringValue = aDecoder.decodeObject(forKey: "intervalValue.stringValue") as? String
        let unit = aDecoder.decodeObject(forKey: "intervalUnit.stringValue") as? String
        
        if let intervalValueStringValue = intervalValueStringValue, let intervalUnit = OrderIntervalTime.fromStringToComponent(unit: unit ?? "") {
            self.init(intervalValue: Int(intervalValueStringValue) ?? 1, intervalUnit: intervalUnit)
        } else {
            return nil
        }
    }
    
    static func fromStringToComponent(unit: String) -> Calendar.Component? {
        switch unit {
        case "month":
            return Calendar.Component.month
        case "day":
            return Calendar.Component.day
        case "hour":
            return Calendar.Component.hour
        default:
            return nil
        }
    }
    
    static func fromComponentToString(component: Calendar.Component) -> String? {
        switch component {
        case .month:
            return "month"
        case .day:
            return "day"
        case .hour:
            return "hour"
        default:
            return nil
        }
    }

    static func getUIPosition(orderIntervalTime: OrderIntervalTime) -> Int {
        switch (orderIntervalTime.intervalValue, orderIntervalTime.intervalUnit) {
        case (1, .hour):
            return 0
        case (1, .day):
            return 1
        case (1, .month):
            return 2
        default:
            return 3
        }
    }

}
