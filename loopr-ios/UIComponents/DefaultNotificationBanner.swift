//
//  DefaultNotificationBanner.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import NotificationBannerSwift

extension NotificationBanner {

    class func generate(title: String, style: BannerStyle) -> NotificationBanner {
        let notificationTitle = NSLocalizedString(title, comment: "")
        let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
        let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
        let banner = NotificationBanner(attributedTitle: attributeString, style: .warning, colors: NotificationBannerStyle())
        return banner
    }
    
}
