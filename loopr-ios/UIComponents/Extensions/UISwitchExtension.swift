//
//  UISwitchExtension.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/16.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
