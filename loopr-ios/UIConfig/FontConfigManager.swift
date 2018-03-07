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
            return "DINNextW1G-Light"
        }
        return "\(currentFont.rawValue)-Light"
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
