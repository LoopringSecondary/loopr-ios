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
    static let backgroundColor: ThemeColorPicker = ["#f5f5f5", "#292929"]
    static let textColor: ThemeColorPicker = ["#222222", "#f5f5f5"]
    static let textLightGreyColor: ThemeColorPicker = ["#00000099", "#f5f5f5"]

    static let barTextColors = ["#222222", "#f5f5f5"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#f5f5f5", "#222222"]
    
    static let tableViewBackgroundColor: ThemeColorPicker = ["#fff", "#222222"]
    
    static let buttonImages: ThemeImagePicker = ThemeImagePicker(images: getImage(from: UIColor.init(rgba: "#f5f5f5")), getImage(from: UIColor.init(rgba: "#292929")))
    
    static func getImage(from color: UIColor, for state: UIControlState = .normal) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorImage!
    }
}
