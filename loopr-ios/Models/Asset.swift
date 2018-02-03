//
//  Asset.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

class Asset {
    
    let symbol: String
    let name: String
    let icon: UIImage
    let enable: Bool
    
    let balance: Double
    
    init(symbol: String, name: String, icon: UIImage, enable: Bool, balance: Double) {
        self.symbol = symbol
        self.name = name
        self.enable = enable
        self.icon = icon
        self.balance = balance
    }
    
}
