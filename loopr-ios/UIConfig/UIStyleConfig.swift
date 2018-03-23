//
//  UIStyleConfig.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

// Colors
enum UIStyleConfig {
    static let defaultTintColor = UIColor.black // UIColor.init(white: 0.2, alpha: 1)
    
    static let systemDefaultBlueTintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1)
    
    static let lineChartFillColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 0.4)
    
    static let tabBarTintColor = UIColor(white: 0, alpha: 1)
    
    static let tableCellSelectedBackgroundColor = UIColor(white: 0.1, alpha: 0.3)
    
    static func getChangeColor(sign: String) -> UIColor {
        let language = Bundle.main.preferredLocalizations.first
        if language == "zh-Hans" {
            if sign == "+" {
                return UIColor.red
            } else {
                return UIColor.init(rgba: "#24DF93")
            }
        } else {
            if sign == "+" {
                return UIColor.init(rgba: "#24DF93")
            } else {
                return UIColor.red
            }
        }
    }
}
