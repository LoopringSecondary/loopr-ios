//
//  UILabelExtension.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/1.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func setTitleFont() {
        let font = FontConfigManager.shared.getTitleFont()
        self.theme_textColor = GlobalPicker.textColor
        self.font = font
    }
    
    func setSubTitleFont() {
        let font = FontConfigManager.shared.getSubtitleFont()
        self.textColor = UIColor(named: "Subtitle")
        self.font = font
    }
    
    func setHeaderFont() {
        let font = FontConfigManager.shared.getHeaderFont()
        self.theme_textColor = GlobalPicker.textColor
        self.font = font
    }
}
