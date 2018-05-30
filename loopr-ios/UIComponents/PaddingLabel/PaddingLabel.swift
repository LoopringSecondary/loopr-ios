//
//  PaddingLabel.swift
//  loopr-ios
//
//  Created by kenshin on 2018/5/29.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
