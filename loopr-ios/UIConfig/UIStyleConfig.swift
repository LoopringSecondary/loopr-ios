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
    
    // TODO: Need to transfer these UIColors to ThemeColorPicker
    static let systemDefaultBlueTintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1)
    static let lineChartFillColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 0.4)
    static let tabBarTintColor = UIColor(white: 0, alpha: 1)
    static let tableCellSelectedBackgroundColor = UIColor.init(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
    static let underlineColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let scale = UIScreen.main.scale / UIScreen.main.nativeScale
      
    static func getChangeColor(change: String, down: Bool? = nil) -> UIColor {
        let firstChar = change.first?.description ?? ""
        // if change == "0.00%", use update
        if firstChar == "" {
            return UIColor.black
        }
        let language = SettingDataManager.shared.getCurrentLanguage()
        if language == Language(name: "zh-Hans") {
            if firstChar == "↓" || firstChar == "-" || down == true {
                return UIColor(named: "Color-green")!
            } else {
                return UIColor(named: "Color-red")!
            }
        } else {
            if firstChar == "↓" || firstChar == "-" || down == false {
                return UIColor(named: "Color-red")!
            } else {
                return UIColor(named: "Color-green")!
            }
        }
    }
}
