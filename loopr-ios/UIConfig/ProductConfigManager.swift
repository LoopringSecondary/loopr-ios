//
//  ProductDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/27.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum Production: String {
    
    // TODO: We will have blue color configuration.
    case loopr = "Loopr Wallet"
    case upwallet = "UP Wallet"
    case vivwallet = "vivwallet"

    static func getCurrent() -> Production {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            print("bundle identifier: \(bundleIdentifier)")
            if bundleIdentifier == "leaf.prod.app" {
                return .upwallet
            } else if bundleIdentifier.contains("viv") {
                return .vivwallet
            }
        }
        return .loopr
    }
    
    static func getProduct() -> String {
        return getCurrent().rawValue
    }
    
    static func getUrlText() -> String {
        switch getCurrent() {
        case .loopr:
            return "https://loopring.wallet.io"
        case .upwallet:
            return "https://upwallet.io"
        case .vivwallet:
            return "https://vivwallet.io"
        }
    }
    
    static func getSocialMedia() -> [SocialMedia] {
        switch getCurrent() {
        case .loopr:
            return getSocialMediaForLoopr()
        case .upwallet:
            return getSocialMediaForUpwallt()
        case .vivwallet:
            return getSocialMediaForVivwallet()
        }
    }
    
    private static func getSocialMediaForLoopr() -> [SocialMedia] {
        return []
    }
    
    private static func getSocialMediaForUpwallt() -> [SocialMedia] {
        let twitter = SocialMedia(type: "Twitter", account: "@UpBlockchainOrg", link: "https://twitter.com/UpBlockchainOrg")
        let instagram = SocialMedia(type: "Instagram", account: "@upwallet", link: "https://www.instagram.com/upwallet")
        let socialMedia: [SocialMedia] = [twitter, instagram]
        return socialMedia
    }

    private static func getSocialMediaForVivwallet() -> [SocialMedia] {
        return []
    }

}
