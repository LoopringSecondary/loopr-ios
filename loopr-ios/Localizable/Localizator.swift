//
//  Localizator.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

func LocalizedString(_ key: String, comment: String) -> String {
    return Localizator.sharedInstance.localizedStringForKey(key)
}

func SetLanguage(_ language: String) -> Bool {
    return Localizator.sharedInstance.setLanguage(language)
}

class Localizator {
    
    // MARK: - Private properties
    private let userDefaults = UserDefaults.standard
    private var dicoLocalization: NSDictionary?

    // Supported Languages
    // Remove a localization configuration is too hard. So we keeps localizaed files.
    /*
    private var availableLanguagesArray = ["DeviceLanguage", "en", "zh-Hans", "zh-Hant", "ja", "ko", "ru"]
    static let map = [
        "en": "English",
        "zh-Hans": "简体中文",
        "zh-Hant": "繁體中文",
        "ja": "日本語",
        "ko": "한국어",
        "ru": "русский"
    ]
    */
    private var availableLanguagesArray = ["DeviceLanguage", "en", "zh-Hans", "zh-Hant", "ko"]
    static let map = [
        "en": "English",
        "zh-Hans": "简体中文",
        "zh-Hant": "繁體中文",
        "ko": "한국어"
    ]

    private let kSaveLanguageDefaultKey = "kSaveLanguageDefaultKey"
    
    // MARK: - Public properties
    var updatedLanguage: String?
    
    // MARK: - Singleton method
    class var sharedInstance: Localizator {
        struct Singleton {
            static let instance = Localizator()
        }
        return Singleton.instance
    }
    
    // MARK: - Init method
    init() {
        
    }
    
    // MARK: - Public custom getter
    
    func getAvailableLanguages() -> [Language] {
        return availableLanguagesArray.map ({ (name) -> Language in
            return Language(name: name)
        }).sorted { (a, b) -> Bool in
            return a.name < b.name
        }
    }
    
    // MARK: - Private instance methods
    
    fileprivate func loadDictionaryForLanguage(_ newLanguage: String) -> Bool {
        let arrayExt = newLanguage.components(separatedBy: "_")
        for ext in arrayExt {
            if let path = Bundle(for: object_getClass(self)!).url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: ext)?.path {
                if FileManager.default.fileExists(atPath: path) {
                    updatedLanguage = newLanguage
                    dicoLocalization = NSDictionary(contentsOfFile: path)
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate func localizedStringForKey(_ key: String) -> String {
        if let dico = dicoLocalization {
            if let localizedString = dico[key] as? String {
                return localizedString
            } else {
                return key
            }
        } else {
            return NSLocalizedString(key, comment: key)
        }
    }

    // Use SetLanguage() to update the language
    fileprivate func setLanguage(_ newLanguage: String) -> Bool {
        if (newLanguage == updatedLanguage) || !availableLanguagesArray.contains(newLanguage) {
            return false
        }
        
        if loadDictionaryForLanguage(newLanguage) {
            // Update the setting. It only works when the application is restarted.
            UserDefaults.standard.set([newLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()

            AppServiceUserManager.shared.updateUserConfigWithUserDefaults()
            
            // runtime at main thread.
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .languageChanged, object: nil)
            }
            return true
        }
        return false
    }
    
}
