//
//  FontConfigManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

enum SupportedFonts: String {
    case System
    case Rubik
}

class FontConfigManager {

    static let shared = FontConfigManager()
    
    var currentFont: SupportedFonts = .Rubik
    
    private init() {
        
    }
    
    func setup() {
        UILabel.appearance().font = FontConfigManager.shared.getDigitalFont()
        UIButton.appearance().titleLabel?.font = FontConfigManager.shared.getDigitalFont()
        UITextField.appearance().font = FontConfigManager.shared.getDigitalFont()
        
        // Font in the tab bar is 10.
        let tabBarItemAttributes = [NSAttributedStringKey.font: getRegularFont(size: 10)]
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .selected)
    }

    func getRegular() -> String {
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getRegularFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getRegular()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func getLight() -> String {
        return "\(currentFont.rawValue)-Light"
    }
    
    func getLightFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getLight()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.light)
    }

    func getMedium() -> String {
        return "\(currentFont.rawValue)-Medium"
    }
    
    func getMediumFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getMedium()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
    }

    func getBold() -> String {
        return "\(currentFont.rawValue)-Bold"
    }
    
    func getBoldFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getBold()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)
    }

    func getDigitalFont(size: CGFloat = 16.0) -> UIFont {
        return getMediumFont(size: size)
    }
    
    func getCharactorFont(size: CGFloat = 16.0) -> UIFont {
        var font: UIFont
        let fontSize = size * UIStyleConfig.scale
        if SettingDataManager.shared.getCurrentLanguage().name == "en" {
            font = getMediumFont(size: size)
        } else if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" {
            font = UIFont(name: "PingfangSC-Regular", size: fontSize)!
        } else {
            font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
        }
        return font
    }
}
