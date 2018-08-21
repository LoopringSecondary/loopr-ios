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
            return UIColor(named: "Color-red")!  // #FA4A6F
        case .info:
            return UIColor.black
        case .none:
            return UIColor.black
        case .success:
            return UIColor.init(rgba: "#22BE75")
        case .warning:
            return UIColor.orange
        }
    }
    
}
