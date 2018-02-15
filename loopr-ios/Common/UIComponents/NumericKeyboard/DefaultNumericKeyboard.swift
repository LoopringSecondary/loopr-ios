//
//  DefaultNumericKeyboard.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

open class DefaultNumericKeyboard: NumericKeyboard {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        dataSource = self
    }
    
}

extension DefaultNumericKeyboard: NumericKeyboardDataSource {
    
    public func numberOfRowsInNumericKeyboard(_ numericKeyboard: NumericKeyboard) -> Int {
        return 4
    }
    
    public func numericKeyboard(_ numericKeyboard: NumericKeyboard, numberOfColumnsInRow row: Row) -> Int {
        return 3
    }
    
    public func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemAtPosition position: Position) -> NumericKeyboardItem {
        var item = NumericKeyboardItem()
        item.title = {
            switch position {
            case (3, 0):
                return "."
            case (3, 1):
                return "0"
            case (3, 2):
                return "x"
            default:
                var index = (0..<position.row).map { self.numericKeyboard(self, numberOfColumnsInRow: $0) }.reduce(0, +)
                index += position.column
                return "\(index + 1)"
            }
        }()
        item.titleColor = {
            switch position {
            case (3, 0):
                return UIColor(white: 0.3, alpha: 1) // .blue
            default:
                return UIColor(white: 0.3, alpha: 1)
            }
        }()
        item.font = .systemFont(ofSize: 40)
        return item
    }
    
}

