//
//  UIButton+RoundBlackButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/26/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setupRoundBlack(height: CGFloat = 47) {
        backgroundColor = UIColor.black
        // TODO: update the color in the highlighted state.
        setBackgroundColor(UIColor.init(white: 0.15, alpha: 1), for: .highlighted)
        clipsToBounds = true
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        layer.cornerRadius = height * 0.5
    }
    
}
