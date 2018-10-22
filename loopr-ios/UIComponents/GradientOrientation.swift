//
//  GradientOrientation.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

// https://medium.com/ios-os-x-development/swift-3-easy-gradients-54ccc9284ce4
enum GradientOrientation {
    case bottomLeftTopRight
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint: CGPoint {
        return points.startPoint
    }
    
    var endPoint: CGPoint {
        return points.endPoint
    }
    
    var points: GradientPoints {
        switch self {
        case .bottomLeftTopRight:
            return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0, y: 0.87), CGPoint(x: 0.87, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
        }
    }
}
