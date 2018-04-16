//
//  NotificationBannerStyle.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class NotificationBannerStyle: BannerColorsProtocol {
    
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:
            return UIColor.red
        case .info:
            return UIColor.black
        case .none:
            return UIColor.black
        case .success:
            return UIColor.green
        case .warning:
            return UIColor.orange
        }
    }
    
}
