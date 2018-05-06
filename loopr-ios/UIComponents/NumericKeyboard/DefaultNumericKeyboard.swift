//
//  DefaultNumericKeyboard.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

open class DefaultNumericKeyboard: NumericKeyboard {
    
    static let height: CGFloat = 220 * UIStyleConfig.scale
    
    var textColor: UIColor! = UIColor.black
    var font: UIFont! = UIFont.init(name: FontConfigManager.shared.getLight(), size: 34*UIStyleConfig.scale) ?? UIFont.systemFont(ofSize: 34*UIStyleConfig.scale)

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
                return ""
            default:
                var index = (0..<position.row).map { self.numericKeyboard(self, numberOfColumnsInRow: $0) }.reduce(0, +)
                index += position.column
                return "\(index + 1)"
            }
        }()

        if position == (3, 2) {
            item.image = UIImage.init(named: "NumericKeyboardDelete")
        }

        item.titleColor = {
            switch position {
            case (3, 0):
                return textColor // .blue
            default:
                return textColor
            }
        }()
        item.font = font
        return item
    }
    
}
