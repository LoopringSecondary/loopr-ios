//
//  UIButton+RoundBlackButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/26/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setupPrimary(height: CGFloat = 48) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        layer.cornerRadius = height * 0.5
        applyGradient(withColors: UIColor.primary)
    }
    
    func setupSecondary(height: CGFloat = 48) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        layer.cornerRadius = height * 0.5
        applyGradient(withColors: UIColor.secondary)
    }
}
