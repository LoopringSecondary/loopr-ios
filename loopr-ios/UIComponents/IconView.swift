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
    
    var circleView: UIView = UIView()
    var circleViewColor: UIColor = UIColor.black
    
    var textColor: UIColor = UIColor.white

    override func draw(_ rect: CGRect) {
        let circleRadius = min(rect.width, rect.height) * 0.5

        // Drawing code
        circleView.frame = CGRect(center: CGPoint(x: rect.midX, y: rect.midY), size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
        circleView.backgroundColor = circleViewColor
        circleView.cornerRadius = circleRadius
        circleView.clipsToBounds = true
        addSubview(circleView)
        showTextInsdieView(circleRadius: circleRadius)
    }
    
    private func showTextInsdieView(circleRadius: CGFloat) {
        symbolLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        symbolLabel.textAlignment = .center
        symbolLabel.textColor = textColor
        let fontSize = (circleRadius*0.625).rounded()
        symbolLabel.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: fontSize)
        symbolLabel.text = symbol
        addSubview(symbolLabel)
    }
}
