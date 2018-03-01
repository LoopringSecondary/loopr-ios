//
//  CircleChart.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class CircleChart: UIView {

    override func draw(_ rect: CGRect) {
        drawCircleFittingInsideView()
    }
    
    internal func drawCircleFittingInsideView() {
        let halfSize: CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth: CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}
