//
//  CircleChart.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class CircleChart: UIView {
    
    var percentage: CGFloat = 1.0
    var showText: Bool = true
    
    var startAngle: CGFloat = 0
    var endAngle: CGFloat = CGFloat.pi*2
    
    var desiredLineWidth: CGFloat = 3
    var padding: CGFloat = 5
    var clockwise: Bool = true
    var textColor: UIColor = UIColor.black
    var textFont: UIFont = UIFont.systemFont(ofSize: 14)
    var strokeColor: CGColor = UIColor.black.cgColor
    var fillColor: CGColor = UIColor.clear.cgColor

    override func draw(_ rect: CGRect) {
        drawCircleFittingInsideView()
        if showText {
            showTextInsdieView()
        }
    }
    
    internal func drawCircleFittingInsideView() {
        let halfSize: CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) - padding*2 ),
            startAngle: startAngle - CGFloat.pi*0.5,
            endAngle: endAngle * percentage - CGFloat.pi*0.5,
            clockwise: clockwise)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = fillColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
    
    internal func showTextInsdieView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        label.textAlignment = .center
        label.textColor = textColor
        label.font = textFont
        percentage = (percentage * 10000).rounded() / 100
        label.text = "\(percentage)%"
        addSubview(label)
    }
}
