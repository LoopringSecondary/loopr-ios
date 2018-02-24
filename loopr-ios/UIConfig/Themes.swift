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
    
    case red   = 0
    case yello = 1
    case blue  = 2
    case night = 3
    
    // MARK: -
    
    static var current: Themes { return Themes(rawValue: ThemeManager.currentThemeIndex)! }
    static var before = Themes.red
    
    // MARK: - Switch Theme
    
    static func switchTo(theme: Themes) {
        before = current
        ThemeManager.setTheme(index: theme.rawValue)
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
        // TODO: Remove the force wrap
        switchTo(theme: Themes(rawValue: defaults.integer(forKey: UserDefaultsKeys.lastedThemeIndex.rawValue))!)
    }
    
    static func saveLastTheme() {
        defaults.set(ThemeManager.currentThemeIndex, forKey: UserDefaultsKeys.lastedThemeIndex.rawValue)
    }

}
