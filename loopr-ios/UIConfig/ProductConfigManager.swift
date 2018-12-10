//
//  ProductDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/27.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum Production: String {
    
    case upwallet = "UP Wallet"
    case vivwallet = "vivwallet"

    static func getCurrent() -> Production {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            print("bundle identifier: \(bundleIdentifier)")
            if bundleIdentifier == "leaf.prod.app" {
                return .upwallet
            } else if bundleIdentifier == "io.upwallet.app" {
                return .upwallet
            } else if bundleIdentifier.contains("viv") {
                return .vivwallet
            }
        }
        return .upwallet
    }

    static func getProduct() -> String {
        return getCurrent().rawValue
    }
    
    static func getUrlText() -> String {
        switch getCurrent() {
        case .upwallet:
            return "https://upwallet.io"
        case .vivwallet:
            return "https://vivwallet.io"
        }
    }
    
    static func getSocialMedia() -> [SocialMedia] {
        switch getCurrent() {
        case .upwallet:
            return getSocialMediaForUpwallt()
        case .vivwallet:
            return getSocialMediaForVivwallet()
        }
    }

    private static func getSocialMediaForUpwallt() -> [SocialMedia] {
        let twitter = SocialMedia(type: "Twitter", account: "@UpBlockchainOrg", link: "https://twitter.com/UpBlockchainOrg")
        let instagram = SocialMedia(type: "Instagram", account: "@upwallet", link: "https://www.instagram.com/upwallet")
        let website = SocialMedia(type: LocalizedString("About", comment: "") + " upwallet.io", account: "", link: getUrlText())
        let socialMedia: [SocialMedia] = [twitter, instagram, website]
        return socialMedia
    }

    private static func getSocialMediaForVivwallet() -> [SocialMedia] {
        let website = SocialMedia(type: LocalizedString("About", comment: "") + " vivwallet.io", account: "", link: getUrlText())
        let socialMedia: [SocialMedia] = [website]
        return socialMedia
    }

}
