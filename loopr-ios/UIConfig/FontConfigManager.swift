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
    case Rubik
}

class FontConfigManager {

    static let shared = FontConfigManager()
    
    // To change the font in the app
    var currentFont: SupportedFonts = .Rubik
    
    private init() {
        // currentFont = getCurrentFontFromLocalStorage()
    }
    
    func setup() {
        UILabel.appearance().font = FontConfigManager.shared.getDigitalFont()
        UIButton.appearance().titleLabel?.font = FontConfigManager.shared.getDigitalFont()
        UITextField.appearance().font = FontConfigManager.shared.getDigitalFont()
        
        // Font in the tab bar is 10.
        let tabBarItemAttributes = [NSAttributedStringKey.font: UIFont(name: FontConfigManager.shared.getCurrentFontName(), size: 10) ?? UIFont.systemFont(ofSize: 10)]
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .selected)
    }

    func setCurrentFont(_ font: SupportedFonts) {
        let defaults = UserDefaults.standard
        defaults.set(font.rawValue, forKey: UserDefaultsKeys.currentFont.rawValue)
    }
    
    func getCurrentFontFromLocalStorage() -> SupportedFonts {
        let defaults = UserDefaults.standard
        if let fontName = defaults.string(forKey: UserDefaultsKeys.currentFont.rawValue) {
            if let validFont = SupportedFonts(rawValue: fontName) {
                return validFont
            }
        }
        return SupportedFonts.Rubik
    }
    
    func getCurrentFontName() -> String {
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getMedium() -> String {
        switch currentFont {
        case .Rubik:
            return "Rubik-Medium"
        }
    }
    
    func getMediumFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getMedium()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func getLight() -> String {
        return "\(currentFont.rawValue)-Light"
    }
    
    func getLightFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getLight()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func getRegular() -> String {
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getRegularFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getRegular()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func getBold() -> String {
        return "\(currentFont.rawValue)-Bold"
    }
    
    func getBoldFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getBold()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    // TODO: Why to use getMediumFont directly?
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
            font = UIFont.systemFont(ofSize: fontSize)
        }
        return font
    }
}
