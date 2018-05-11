//
//  Double+Extension.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension Double {

    func withCommas(minimumFractionDigits: Int = 4) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        if let formattedNumber = numberFormatter.string(from: NSNumber(value: self)) {
            return formattedNumber
        } else {
            return self.description
        }        
    }

}
