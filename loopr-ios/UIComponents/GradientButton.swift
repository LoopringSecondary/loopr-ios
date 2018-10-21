//
//  HighlightButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    let gradient = CAGradientLayer()
    var gradientColors: [UIColor] = UIColor.secondary
    var gradientHightlightedColors: [UIColor] = UIColor.secondaryHighlighted
    var gradientOrientation: GradientOrientation = .topRightBottomLeft

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        gradient.name = "gradientLayer"
    
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        layer.cornerRadius = height * 0.5
        applyGradientLayer(withColors: gradientColors, gradientOrientation: gradientOrientation)
    }
    
    func setPrimaryColor(gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        setGradient(colors: UIColor.primary, hightlightedColors: UIColor.primaryHighlighted, gradientOrientation: orientation)
    }
    
    func setSecondaryColor(gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        setGradient(colors: UIColor.secondary, hightlightedColors: UIColor.secondaryHighlighted, gradientOrientation: orientation)
    }
    
    func setRed(gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        setGradient(colors: [UIColor.init(rgba: "#DD5252"), UIColor.init(rgba: "#D53535")], hightlightedColors: [UIColor.init(rgba: "#DD5252"), UIColor.init(rgba: "#D53535")], gradientOrientation: orientation)
    }

    func setBlack(gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        setGradient(colors: [UIColor.dark3, UIColor.dark3], hightlightedColors: [UIColor.dark3, UIColor.dark3], gradientOrientation: orientation)
    }
    
    func setGradient(colors: [UIColor], hightlightedColors: [UIColor], gradientOrientation orientation: GradientOrientation = .topRightBottomLeft) {
        self.gradientColors = colors
        self.gradientHightlightedColors = hightlightedColors
        self.gradientOrientation = orientation
        applyGradientLayer(withColors: self.gradientColors, gradientOrientation: self.gradientOrientation)
    }

    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                applyGradientLayer(withColors: gradientHightlightedColors, gradientOrientation: gradientOrientation)
            } else {
                applyGradientLayer(withColors: gradientColors, gradientOrientation: gradientOrientation)
            }
        }
    }

    func applyGradientLayer(withColors colors: [UIColor], gradientOrientation orientation: GradientOrientation) {
        
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }

}
