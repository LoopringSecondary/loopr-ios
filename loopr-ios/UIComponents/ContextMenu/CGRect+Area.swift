//
//  CGRect+Area.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension CGRect {

    func rect(point: CGPoint, xRemainder: Bool, yRemainder: Bool) -> CGRect {
        let xDiv = divided(atDistance: point.x, from: .minXEdge)
        let x = xRemainder ? xDiv.remainder : xDiv.slice
        let yDiv = x.divided(atDistance: point.y, from: .minYEdge)
        return yRemainder ? yDiv.remainder : yDiv.slice
    }

    func area(corner: SourceViewCorner) -> CGFloat {
        let (xRemainder, yRemainder): (Bool, Bool)
        switch corner.position {
        case .topLeft:
            (xRemainder, yRemainder) = (false, false)
        case .topRight:
            (xRemainder, yRemainder) = (true, false)
        case .bottomLeft:
            (xRemainder, yRemainder) = (false, true)
        case .bottomRight:
            (xRemainder, yRemainder) = (true, true)
        }
        let frame = rect(point: corner.point, xRemainder: xRemainder, yRemainder: yRemainder)
        return frame.width * frame.height
    }

}
