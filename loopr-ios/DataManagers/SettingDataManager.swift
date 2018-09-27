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

    // MARK: Language
    func getSupportedLanguages() -> [Language] {
        /*
        let languageNames = Bundle.main.localizations
        let languages = languageNames.filter ({ (languageName) -> Bool in
            return languageName != "Base"
        }).map ({ (name) -> Language in
            return Language(name: name)
        }).sorted { (a, b) -> Bool in
            return a.name < b.name
        }
        */
        return Localizator.sharedInstance.getAvailableLanguages().filter({ (language) -> Bool in
            return language.name != "DeviceLanguage"
        })
    }
    
    func getCurrentLanguage() -> Language {
        if Localizator.sharedInstance.updatedLanguage != nil {
            return Language(name: Localizator.sharedInstance.updatedLanguage!)
        }
        
        if let languageName = Bundle.main.preferredLocalizations.first {
            return Language(name: languageName)
        }
        return Language(name: "en")
    }
    
    // MARK: Currency
    func getSupportedCurrencies() -> [Currency] {
        let currencyNames = ["CNY", "USD"]
        let currencies = currencyNames.filter ({ (currencyName) -> Bool in
            return currencyName != "Base"
        }).map { (name) -> Currency in
            return Currency(name: name)
        }
        return currencies
    }
    
    func setCurrentCurrency(_ currency: Currency) {
        let defaults = UserDefaults.standard
        defaults.set(currency.name, forKey: UserDefaultsKeys.currentCurrency.rawValue)
        PriceDataManager.shared.startGetPriceQuote()
    }
    
    func getCurrentCurrency() -> Currency {
        let defaults = UserDefaults.standard
        if let currencyName = defaults.string(forKey: UserDefaultsKeys.currentCurrency.rawValue) {
            return Currency(name: currencyName)
        } else {
            // TODO: we don't support hongkong dollar now.
            if getCurrentLanguage() == Language(name: "zh-Hans") {
                setCurrentCurrency(Currency(name: "CNY"))
                return Currency(name: "CNY")
            } else {
                setCurrentCurrency(Currency(name: "USD"))
                return Currency(name: "USD")
            }
        }
    }

    // MARK: Hide small assets
    func getHideSmallAssets() -> Bool {
        /*
        var result = false
        let defaults = UserDefaults.standard
        // If the value is absent or can't be converted to a BOOL, NO will be returned.
        result = defaults.bool(forKey: UserDefaultsKeys.showSmallAssets.rawValue)
        return !result
        */
        return false
    }
    
    func setHideSmallAssets(_ hide: Bool) {
        let showSmallAssets = !hide
        let defaults = UserDefaults.standard
        defaults.set(showSmallAssets, forKey: UserDefaultsKeys.showSmallAssets.rawValue)
    }
    
    // MARK: Hide other pairs
    func getHideOtherPairs() -> Bool {
        let defaults = UserDefaults.standard
        // If the value is absent or can't be converted to a BOOL, NO will be returned.
        let showOtherPairs = defaults.bool(forKey: UserDefaultsKeys.showOtherPairs.rawValue)
        return !showOtherPairs
    }
    
    func setHideOtherPair(_ hide: Bool) {
        let showOtherPairs = !hide
        let defaults = UserDefaults.standard
        defaults.set(showOtherPairs, forKey: UserDefaultsKeys.showOtherPairs.rawValue)
    }

    // between 0.001 - 0.05
    func setLrcFeeRatio(_ newValue: Double) {
        let lrcFeeRatio: Double
        if newValue < 0.001 {
            lrcFeeRatio = 0.001
        } else if newValue > 0.05 {
            lrcFeeRatio = 0.05
        } else {
            lrcFeeRatio = newValue
        }
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: UserDefaultsKeys.useLrcFeeRatioUserDefineValue.rawValue)
        defaults.set(lrcFeeRatio, forKey: UserDefaultsKeys.lrcFeeRatio.rawValue)
    }

    func getLrcFeeRatio() -> Double {
        let defaults = UserDefaults.standard
        let useLrcFeeRatioUserDefineValue = defaults.bool(forKey: UserDefaultsKeys.useLrcFeeRatioUserDefineValue.rawValue)
        if useLrcFeeRatioUserDefineValue {
            let lrcFeeRatio = defaults.double(forKey: UserDefaultsKeys.lrcFeeRatio.rawValue)
            return lrcFeeRatio
        } else {
            return 0.002
        }
    }
    
    func getLrcFeeRatioDescription() -> String {
        let numberFormatter = NumberFormatter()
        return String(SettingDataManager.shared.getLrcFeeRatio()*100) + numberFormatter.percentSymbol
    }

    func getMarginSplit() -> Double {
        return 0.5
    }

}
