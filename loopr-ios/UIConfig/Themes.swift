//
//  Themes.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftTheme

private let defaults = UserDefaults.standard

enum Themes: Int {
    
    case day = 0
    case night = 1
    
    // MARK: -
    
    static var current: Themes {
        // TODO: Remove the force wrap
        let theme = Themes(rawValue: ThemeManager.currentThemeIndex)
        guard theme != nil else {
            return Themes.day
        }
        return theme!
    }
    static var before = Themes.day
    
    // MARK: - Switch Theme
    
    static func switchTo(themeIndex: Int) {
        let theme = Themes(rawValue: themeIndex)
        guard theme != nil else {
            return
        }
        
        switchTo(theme: theme!)
    }
    
    static func switchTo(theme: Themes) {
        before = current
        ThemeManager.setTheme(index: theme.rawValue)
        Themes.saveLastTheme()
    }
    
    static func switchToNext() {
        var next = ThemeManager.currentThemeIndex + 1
        if next > 2 { next = 0 } // cycle and without Night
        switchTo(theme: Themes(rawValue: next)!)
    }
    
    // MARK: - Switch Night
    
    static func switchNight(isToNight: Bool) {
        switchTo(theme: isToNight ? .night : before)
    }
    
    static func isNight() -> Bool {
        return current == .night
    }
    
    // MARK: - Save & Restore
    
    static func restoreLastTheme() {
        let lastedThemeIndex = defaults.integer(forKey: UserDefaultsKeys.lastedThemeIndex.rawValue)
        switchTo(themeIndex: lastedThemeIndex)
    }
    
    static func saveLastTheme() {
        defaults.set(ThemeManager.currentThemeIndex, forKey: UserDefaultsKeys.lastedThemeIndex.rawValue)
    }

}
