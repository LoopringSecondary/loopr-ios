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
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setSubTitleFont() {
        let font = FontConfigManager.shared.getSubtitleFont()
        self.theme_textColor = ["#00000099", "#ffffff66"]
        self.font = font
    }
    
    func setHeaderFont() {
        let font = FontConfigManager.shared.getHeaderFont()
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setMarket() {
        if let text = self.text {
            let range = (text as NSString).range(of: "/\\w*\\d*", options: .regularExpression)
            let attribute = NSMutableAttributedString.init(string: text)
            attribute.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.dark3], range: range)
            self.attributedText = attribute
        }
    }
}
