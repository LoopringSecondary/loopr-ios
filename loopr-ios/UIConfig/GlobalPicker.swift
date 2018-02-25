//
//  GlobalPicker.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    // Default values
    static let backgroundColor: ThemeColorPicker = ["#fff", "#000"]
    static let textColor: ThemeColorPicker = ["#000", "#fff"]

    static let barTextColors = ["#000", "#fff"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#fff", "#000"]
    
}
