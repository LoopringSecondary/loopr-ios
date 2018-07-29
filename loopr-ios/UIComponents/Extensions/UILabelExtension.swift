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
    
    func setHeaderDigitFont() {
        let font = FontConfigManager.shared.getDigitalFont(size: 32)
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setTitleDigitFont() {
        let font = FontConfigManager.shared.getDigitalFont()
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setSubTitleDigitFont() {
        let font = FontConfigManager.shared.getDigitalFont(size: 12)
        self.theme_textColor = ["#00000099", "#ffffff66"]
        self.font = font
    }
    
    func setHeaderCharFont() {
        let font = FontConfigManager.shared.getCharactorFont(size: 30)
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setTitleCharFont() {
        let font = FontConfigManager.shared.getCharactorFont(size: 14)
        self.theme_textColor = ["#000000cc", "#ffffffcc"]
        self.font = font
    }
    
    func setSubTitleCharFont() {
        let font = FontConfigManager.shared.getCharactorFont(size: 13)
        self.theme_textColor = ["#00000099", "#ffffff66"]
        self.font = font
    }
    
    func setMarket() {
        if let text = self.text {
            let range = (text as NSString).range(of: "-\\w*\\d*", options: .regularExpression)
            let attribute = NSMutableAttributedString.init(string: text)
            attribute.addAttributes([NSAttributedStringKey.font: FontConfigManager.shared.getRegularFont(size: 14)], range: range)
            self.attributedText = attribute
        }
    }
}
