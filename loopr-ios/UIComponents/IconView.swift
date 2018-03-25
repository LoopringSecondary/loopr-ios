//
//  IconView.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/25/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class IconView: UIView {
    
    var symbol: String = ""
    var symbolLabel: UILabel = UILabel()
    
    var width: CGFloat = 5
    
    var backgroundView: UIView = UIView()
    var backgroundViewColor: UIColor = UIColor.black
    
    var textColor: UIColor = UIColor.white

    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundView.frame = rect
        backgroundView.backgroundColor = backgroundViewColor
        backgroundView.cornerRadius = rect.width * 0.5
        addSubview(backgroundView)

        showTextInsdieView()
    }
    
    func showTextInsdieView() {
        symbolLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        symbolLabel.textAlignment = .center
        symbolLabel.textColor = textColor
        symbolLabel.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 10)
        symbolLabel.text = symbol
        addSubview(symbolLabel)
    }

}
