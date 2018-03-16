//
//  Asset.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Asset: CustomStringConvertible {

    let symbol: String
    var name: String
    var icon: UIImage?
    var enable: Bool
    var balance: String
    var allowance: String
    var display: Double
    var description: String
    
    init(json: JSON) {
        
        self.name = ""
        self.enable = true
        self.display = 0
        self.description = self.name
        self.symbol = json["symbol"].stringValue
        self.balance = json["balance"].stringValue
        self.allowance = json["allowance"].stringValue
        self.icon = UIImage(named: self.symbol) ?? nil
    }
    
}
