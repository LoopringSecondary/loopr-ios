//
//  Asset.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

// TODO: What is difference between Asset and Token? Could we merge these two classes?
class Asset: CustomStringConvertible, Equatable {

    let symbol: String
    var name: String
    var icon: UIImage?
    var enable: Bool
    var balance: String
    var allowance: String  // TODO: why allowance is String?
    var display: String
    var description: String
    
    init(json: JSON) {
        self.name = ""
        self.enable = true
        self.display = "0"
        self.description = self.name
        self.symbol = json["symbol"].stringValue
        self.balance = json["balance"].stringValue
        self.allowance = json["allowance"].stringValue
        self.icon = UIImage(named: self.symbol) ?? nil
    }
    
    init(symbol: String) {
        self.symbol = symbol
        self.name = ""
        self.enable = true
        self.display = "0"
        self.description = self.name
        self.balance = "0"
        self.allowance = "0"
        self.icon = UIImage(named: self.symbol) ?? nil
    }

    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.symbol == rhs.symbol
    }

}
