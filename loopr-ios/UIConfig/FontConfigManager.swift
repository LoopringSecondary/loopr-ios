//
//  FontConfigManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import FontBlaster
import Foundation
import UIKit

enum SupportedFonts: String {
    case DIN
    case OpenSans
    case Roboto
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
        FontBlaster.debugEnabled = true
        FontBlaster.blast { (fonts) -> Void in
            print("Loaded Fonts", fonts)
        }

        UILabel.appearance().font = FontConfigManager.shared.getLabelFont()
        UIButton.appearance().titleLabel?.font = FontConfigManager.shared.getLabelFont()
        UITextField.appearance().font = FontConfigManager.shared.getLabelFont()
        
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
        return SupportedFonts.DIN
    }
    
    func getCurrentFontName() -> String {
        if currentFont == .DIN {
            return "DINNextLTPro-Regular"
        }
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getMedium() -> String {
        switch currentFont {
        case .DIN:
            return "DINNextLTPro-Medium"
        case .OpenSans:
            return "OpenSans-SemiBold"
        case .Roboto:
            return "Roboto-Medium"
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
        if currentFont == .DIN {
            return "DINNextLTPro-Light"
        }
        return "\(currentFont.rawValue)-Light"
    }
    
    func getLightFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getLight()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func getRegular() -> String {
        if currentFont == .DIN {
            return "DINNextLTPro-Regular"
        }
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getRegularFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getRegular()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func getBold() -> String {
        if currentFont == .DIN {
            return "DIN-Bold"
        }
        return "\(currentFont.rawValue)-Bold"
    }
    
    func getBoldFont(size: CGFloat = 16.0) -> UIFont {
        let fontName = getBold()
        let fontSize = size * UIStyleConfig.scale
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func getNavigationTitleFont() -> UIFont {
        return UIFont(name: getMedium(), size: 16)!
    }
    
    func getHeaderFont() -> UIFont {
        return getMediumFont(size: 32)
    }
    
    func getTitleFont() -> UIFont {
        return getMediumFont()
    }
    
    func getSubtitleFont() -> UIFont {
        return getMediumFont(size: 12)
    }

    func getLabelFont(size: CGFloat = 16.0) -> UIFont {
        return getMediumFont(size: size)
    }

    func getButtonTitleFont(size: CGFloat = 16.0) -> UIFont {
        return getMediumFont(size: size)
    }

}
