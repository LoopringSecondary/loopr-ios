//
//  GlobalPicker.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import SwiftTheme

// TODO: We have to migrate to ColorPicker
enum GlobalPicker {

    // text colors
    private static let textColors = ["#000000cc", "#ffffffcc"]
    static let textColor = ThemeColorPicker.pickerWithColors(textColors)
    
    private static let contrastTextColors = ["#ffffffcc", "#000000cc"]
    static let contrastTextColor = ThemeColorPicker.pickerWithColors(contrastTextColors)
    
    static let textLightColor: ThemeColorPicker = ["#00000099", "#ffffff66"]
    static let contrastTextLightColor: ThemeColorPicker = ["#ffffff66", "#00000099"]
  
    private static let barTextColors = ["#00000099", "#ffffffcc"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    
    // navigation title attributes
    static let titleAttributes = GlobalPicker.textColors.map { hexString -> [NSAttributedStringKey : NSObject] in
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        return [
            NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
            NSAttributedStringKey.font: FontConfigManager.shared.getDigitalFont(size: 18),
            NSAttributedStringKey.shadow: shadow
        ]
    }
        
    static let keyboard: ThemeImagePicker = ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#8f8f8f")))
    static let keyboardHighlight: ThemeImagePicker = ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#9f9f9f")))
    static let back: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Back-button-light"), #imageLiteral(resourceName: "Back-button-dark"))
    static let backHighlight: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Back-button-light").alpha(0.3), #imageLiteral(resourceName: "Back-button-dark").alpha(0.3))
    static let indicator: ThemeImagePicker = ThemeImagePicker(images: UIImage(named: "Indicator-light\(ColorTheme.getTheme())")!, UIImage(named: "Indicator-dark\(ColorTheme.getTheme())")!)
    static let close: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Close-light"), #imageLiteral(resourceName: "Close-dark"))
    static let closeHighlight: ThemeImagePicker = ThemeImagePicker(images: #imageLiteral(resourceName: "Close-light").alpha(0.3), #imageLiteral(resourceName: "Close-dark").alpha(0.3))

}
