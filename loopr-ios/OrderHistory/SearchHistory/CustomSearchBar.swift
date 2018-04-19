//
//  CustomSearchBar.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    var preferredFont: UIFont!
    
    var preferredTextColor: UIColor!
    
    override func draw(_ rect: CGRect) {
        if let index = indexOfSearchFieldInSubviews() {
            let searchField: UITextField = (subviews[0] ).subviews[index] as! UITextField
            searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            searchField.backgroundColor = barTintColor
        }
        
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: frame.size.width, y: 0.0)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        layer.addSublayer(shapeLayer)
        super.draw(rect)
    }
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        searchBarStyle = UISearchBarStyle.prominent
        isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] 
        for (i, subview) in searchBarView.subviews.enumerated() where subview is UITextField {
            index = i
            break
        }
        return index
    }
}
