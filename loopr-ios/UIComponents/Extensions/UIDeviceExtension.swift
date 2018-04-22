//
//  UIDeviceExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIDevice {

    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }

}
