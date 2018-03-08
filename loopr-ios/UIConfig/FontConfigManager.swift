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
    case Lato
    case OpenSans
}

class FontConfigManager {

    static let shared = FontConfigManager()
    
    var currentFont: SupportedFonts = .OpenSans
    
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
        
        // TODO: unsafe. Fix it.
        let tabBarItemAttributes = [NSAttributedStringKey.font: UIFont(name: FontConfigManager.shared.getCurrentFontName(), size: 10)!]
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
    
    func getRegular() -> String {
        if currentFont == .DIN {
            return "DINNextLTPro-Regular"
        }
        return "\(currentFont.rawValue)-Regular"
    }
    
    func getLight() -> String {
        if currentFont == .DIN {
            return "DINNextW1G-Light"
        }
        return "\(currentFont.rawValue)-Light"
    }
    
    func getBold() -> String {
        if currentFont == .DIN {
            return "DIN-Bold"
        }
        return "\(currentFont.rawValue)-Bold"
    }

    func getLabelFont() -> UIFont {
        if currentFont == .DIN {
            // TODO: unsafe. fix it.
            return UIFont(name: "DINNextLTPro-Regular", size: 17.0)!
        }
        // TODO: unsafe. fix it.
        return UIFont(name: "\(currentFont.rawValue)-Regular", size: 17.0)!
    }

    func getButtonTitleLabelFont() -> UIFont {
        if currentFont == .DIN {
            // TODO: unsafe. fix it.
            return UIFont(name: "DIN-Bold", size: 17.0)!
        }
        // TODO: unsafe. fix it.
        return UIFont(name: "\(currentFont.rawValue)-Bold", size: 17.0)!
    }
}
