//
//  UIButton+RoundBlackButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/26/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setupPrimary(height: CGFloat = 48, gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        layer.cornerRadius = height * 0.5
        applyGradient(withColors: UIColor.primary, gradientOrientation: orientation)
    }
    
    func setupSecondary(height: CGFloat = 48, gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        layer.cornerRadius = height * 0.5
        applyGradient(withColors: UIColor.secondary, gradientOrientation: orientation)
    }
    
    func setupBlack(height: CGFloat = 48) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        layer.cornerRadius = height * 0.5
        setBackgroundColor(.dark3, for: .normal)
    }
    
    func setupRed(height: CGFloat = 48, gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        layer.cornerRadius = height * 0.5
        applyGradient(withColors: [UIColor.init(rgba: "#DD5252"), UIColor.init(rgba: "#D53535")], gradientOrientation: orientation)
    }
}
