//
//  UIButton+RoundBlackButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/26/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setupSecondary(height: CGFloat = 48) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0*UIStyleConfig.scale)
        applyGradient(withColors: UIColor.secondary)
        layer.cornerRadius = height * 0.5
    }
    
    func setupPrimary(height: CGFloat = 48) {
        setTitleColor(.gray, for: .disabled)
        setTitleColor(.black, for: .normal)
        setBackgroundColor(UIColor.white, for: .normal)
        setBackgroundColor(UIColor.init(white: 0.85, alpha: 1), for: .highlighted)
        clipsToBounds = true
        titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0*UIStyleConfig.scale)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.cornerRadius = height * 0.5
    }

}
