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
    
    func getLight() -> String {
        if currentFont == .DIN {
            return "DINNextLTPro-Light"
        }
        return "\(currentFont.rawValue)-Light"
    }

    func getRegular() -> String {
        if currentFont == .DIN {
            return "DINNextLTPro-Regular"
        }
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getRegularFont(size: CGFloat = 17.0) -> UIFont {
        let fontSize = size * UIStyleConfig.scale
        if currentFont == .DIN {
            return UIFont(name: "DINNextLTPro-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
        return UIFont(name: "\(currentFont.rawValue)-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func getNavigationTitleFont() -> UIFont {
        return UIFont(name: getMedium(), size: 17)!
    }
    
    func getHeaderFont() -> UIFont {
        return getRegularFont(size: 21)
    }
    
    func getTitleFont() -> UIFont {
        return getRegularFont()
    }
    
    func getSubtitleFont() -> UIFont {
        return getRegularFont(size: 13)
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
    
    func getBold() -> String {
        if currentFont == .DIN {
            return "DIN-Bold"
        }
        return "\(currentFont.rawValue)-Bold"
    }

    func getLabelFont(size: CGFloat = 17.0) -> UIFont {
        let fontSize = size * UIStyleConfig.scale
        if currentFont == .DIN {
            return UIFont(name: "DINNextLTPro-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
        return UIFont(name: "\(currentFont.rawValue)-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func getButtonTitleLabelFont(size: CGFloat = 17.0) -> UIFont {
        let fontSize = size * UIStyleConfig.scale
        if currentFont == .DIN {
            return UIFont(name: "DIN-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
        }
        return UIFont(name: "\(currentFont.rawValue)-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }

}
