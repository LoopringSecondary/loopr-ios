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
    var textColor: UIColor = UIColor.black
    var textFont: UIFont = UIFont.systemFont(ofSize: 14)
    var strokeColor: CGColor = UIColor.black.cgColor
    var fillColor: CGColor = UIColor.clear.cgColor
    
    let backgroundShapeLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backgroundShapeLayer)
        layer.addSublayer(shapeLayer)
        addSubview(label)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(backgroundShapeLayer)
        layer.addSublayer(shapeLayer)
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        update()
    }
    
    func update() {
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
            clockwise: true)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = fillColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = desiredLineWidth
        
        let circlePathInGrey = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) - padding*2 ),
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false)
        backgroundShapeLayer.path = circlePathInGrey.cgPath
        backgroundShapeLayer.fillColor = fillColor
        backgroundShapeLayer.strokeColor = UIColor.init(white: 0.0, alpha: 0.1).cgColor
        backgroundShapeLayer.lineWidth = desiredLineWidth
    }
    
    internal func showTextInsdieView() {
        label.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        label.textAlignment = .center
        label.textColor = textColor
        label.font = textFont
        let percentage = (self.percentage * 10000).rounded() / 100
        label.text = String(format: "%.0f", percentage) + "%"
    }
}
