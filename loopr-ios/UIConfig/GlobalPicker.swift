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
    static let backgroundColor: ThemeColorPicker = ["#f5f5f5", "#222222"]
    static let cardBackgroundColor: ThemeColorPicker = ["#f5f5f5", "#292929"]
    static let cardHighLightColor: ThemeColorPicker = ["#00000099", "#383838"]
    
    // text colors
    static let textColors = ["#000000cc", "#ffffffcc"]
    static let textColor = ThemeColorPicker.pickerWithColors(textColors)
    static let textLightColor: ThemeColorPicker = ["#00000099", "#ffffff66"]
  
    static let barTextColors = ["#00000099", "#ffffffcc"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#f5f5f5", "#222222"]
    
    // button images
    static let button: ThemeImagePicker = ThemeImagePicker(images: getImage(from: UIColor.init(rgba: "#f5f5f5")), getImage(from: UIColor.init(rgba: "#292929")))
    static let buttonHighlight: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Header-plain"), #imageLiteral(resourceName: "Header-plain"))
    static let backButton: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Back-button-light"), #imageLiteral(resourceName: "Back-button-dark"))
    static let backButtonHighlight: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Back-button-light").alpha(0.3), #imageLiteral(resourceName: "Back-button-dark").alpha(0.3))
    static let indicator: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Indicator-light"), #imageLiteral(resourceName: "Indicator-dark"))
    
    static func getImage(from color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorImage!
    }
}
