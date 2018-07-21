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
    
    case light = 0
    case dark = 1

    static var current: Themes {
        let theme = Themes(rawValue: ThemeManager.currentThemeIndex)
        guard theme != nil else {
            return Themes.dark
        }
        return theme!
    }
    static var before = Themes.light
    
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
    
    static func switchDark(isToDark: Bool) {
        switchTo(theme: isToDark ? .dark : before)
    }
    
    static func isDark() -> Bool {
        return current == .dark
    }
    
    static func getTheme() -> String {
        return isDark() ? "dark" : "light"
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
