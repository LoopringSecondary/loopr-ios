//
//  DefaultNumericKeyboard.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

open class DefaultNumericKeyboard: NumericKeyboard, NumericKeyboardDelegate {
    
    static let height: CGFloat = 220 * UIStyleConfig.scale
    
    var textColor: UIColor! = UIColor.black
    var font: UIFont! = UIFont.init(name: FontConfigManager.shared.getLight(), size: 34*UIStyleConfig.scale) ?? UIFont.systemFont(ofSize: 34*UIStyleConfig.scale)
    
    open weak var delegate2: DefaultNumericKeyboardDelegate?
    var currentText: String = ""
    var isIntegerOnly: Bool = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        currentText = ""
        dataSource = self
        delegate = self
    }

    public func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        switch (position.row, position.column) {
        case (3, 0):
            if isIntegerOnly {
                
            } else {
                if !currentText.contains(".") {
                    currentText += "."
                    // TODO: add a shake animation to the item at (3, 0)
                }
            }
        case (3, 1):
            currentText += "0"
        case (3, 2):
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
        default:
            let itemValue = position.row * 3 + position.column + 1
            currentText += String(itemValue)
        }
        delegate2?.numericKeyboard(self, currentTextDidUpdate: currentText)
        collectionView.reloadData()
    }

    public func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemLongPressed item: NumericKeyboardItem, atPosition position: Position) {
        print("Long pressed keyboard: (\(position.row), \(position.column))")
        if (position.row, position.column) == (3, 2) {
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
        }
        delegate2?.numericKeyboard(self, currentTextDidUpdate: currentText)
        collectionView.reloadData()
    }
}

public protocol DefaultNumericKeyboardDelegate: class {
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, currentTextDidUpdate currentText: String)
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
                if isIntegerOnly {
                    return ""
                } else {
                    return "."
                }
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
                if currentText.contains(".") {
                    // TODO: set a grey color. Need a better color or an icon.
                    return UIColor.gray
                }
                return textColor
            default:
                return textColor
            }
        }()
        item.font = font

        if position == (3, 0) {
            item.backgroundColor = UIColor.clear
            item.selectedBackgroundColor = UIColor.clear
        }

        return item
    }
    
}
