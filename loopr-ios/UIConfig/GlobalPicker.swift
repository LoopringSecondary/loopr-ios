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
    static let textLightGreyColor: ThemeColorPicker = ["#00000099", "#fff"]

    static let barTextColors = ["#000", "#fff"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#f5f5f5", "#000"]
    
    static let tableViewBackgroundColor: ThemeColorPicker = ["#f5f5f5", "#121212"]
}
