//
//  SettingDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SettingDataManager {
    
    static let shared = SettingDataManager()
    
    private init() {
        
    }

    func getSupportedLanguages() -> [Language] {
        let languageNames = Bundle.main.localizations
        let languages = languageNames.filter ({ (languageName) -> Bool in
            return languageName != "Base"
        }).map { (name) -> Language in
            return Language(name: name)
        }
        return languages
    }

    func setCurrentLanguage(_ language: Language) {
        let defaults = UserDefaults.standard
        defaults.set(language.name, forKey: UserDefaultsKeys.currentLanguage.rawValue)
    }
    
    func getCurrentLanguage() -> Language {
        let defaults = UserDefaults.standard
        if let languageName = defaults.string(forKey: UserDefaultsKeys.currentLanguage.rawValue) {
            return Language(name: languageName)
        }

        if let languageName = Bundle.main.preferredLocalizations.first {
            return Language(name: languageName)
        }
        
        return Language(name: "en")
    }

}
