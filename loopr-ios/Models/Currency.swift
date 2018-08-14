//
//  Currency.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/21.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

class Currency: Equatable, CustomStringConvertible {
    
    var locale: String
    let name: String
    let icon: UIImage?
    var description: String
    
    let map = [
        "en_US": "USD",
        "zh_CN": "CNY",
        "zh_HK": "HKD"
    ]
    
    init(name: String) {
        self.name = name
        self.icon = UIImage(named: name)
        self.locale = "en_US"
        self.description = LocalizedString(name, comment: "")
        map.forEach { (k, v) in
            if v == name {
                self.locale = k
            }
        }
    }

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.name == rhs.name
    }
}
