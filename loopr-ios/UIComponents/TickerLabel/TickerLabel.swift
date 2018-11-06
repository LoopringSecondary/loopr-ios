//
//  TickerLabel.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

enum TickerLabelScrollDirection {
    case up
    case down
}

class TickerCharacterLabel: UILabel {
    var animationDidCompleteBlock: ((_ label: TickerCharacterLabel) -> Void)?

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if animationDidCompleteBlock != nil {
            animationDidCompleteBlock!(self)
        }
    }
}

class TickerLabel: UIView {
    
    var font: UIFont = UIFont.systemFont(ofSize: 30)
    var currencySymbolFont: UIFont = UIFont.systemFont(ofSize: 20)
    
    @IBInspectable var textColor: UIColor = UIColor.white
    
    // TODO: This may conflict to isOneDirection
    var scrollDirection: TickerLabelScrollDirection = .up
    var isOneDirection = true

    var shadowColor: UIColor = UIColor.clear
    
    var shadowOffset: CGSize = CGSize()
    
    var textAlignment: NSTextAlignment = .left
    
    @IBInspectable var animationDuration: CGFloat = 1.0
    
    @IBInspectable var text: String = ""
    
    private var characterViews: [TickerCharacterLabel] = []
    
    private var characterWidth: CGFloat = 20
    
    private var charactersView: UIView = UIView()
    
    private var labelViewsToRemove = Set<TickerCharacterLabel>()
    
    // MARK: - Initialization
    
    func initializeLabel() {
        characterViews = []

        labelViewsToRemove = Set<TickerCharacterLabel>()
        charactersView = UIView(frame: bounds)
        charactersView.clipsToBounds = true
        charactersView.backgroundColor = UIColor.clear
        addSubview(charactersView)
        // font = UIFont.systemFont(ofSize: 36.0)
        textColor = UIColor.white
        // animationDuration = 1.0
        
        // setFont(UIFont.systemFont(ofSize: 36.0))
        characterWidth = "8".size(withAttributes: [NSAttributedStringKey.font: font]).width
        for characterView in characterViews {
            characterView.font = font
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        initializeLabel()
    }
    
    // MARK: - Text Update
    func setText(_ text: String) {
        setText(text, animated: true)
    }
    
    func setText(_ text: String, animated: Bool) {
        if self.text == text {
            return
        }
        let oldTextLength: Int = self.text.count
        let newTextLength: Int = text.count
        
        if newTextLength > oldTextLength {
            let textLengthDelta: Int = newTextLength - oldTextLength
            for _ in 0..<textLengthDelta {
                insertNewCharacterLabel()
            }
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutCharacterLabels(text: text)
        } else if newTextLength < oldTextLength {
            let textLengthDelta: Int = oldTextLength - newTextLength
            for _ in 0..<textLengthDelta {
                removeLastCharacterLabel(animated)
            }
            // TODO: We may have the wired animation here. labelDidCompleteRemovealAnimation(aLabel) should fix it.
            if !animated {
                invalidateIntrinsicContentSize()
                setNeedsLayout()
                layoutCharacterLabels(text: text)
            }
            
        }
        /*
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutCharacterLabels()
        */
        
        var oldValue = Double(self.text)
        if oldValue == nil {
            oldValue = 0
        }
        var newValue = Double(text)
        if newValue == nil {
            newValue = 0
        }
        let oneScrollDirection: TickerLabelScrollDirection = oldValue! > newValue! ? .up : .down
        
        for i in 0 ..< characterViews.count {
            
            let characterView = characterViews[i]
            
            let character: String = (text as NSString).substring(with: NSRange(location: i, length: 1))
            let oldCharacter: String? = characterView.text
            characterView.text = character
            if animated && !(oldCharacter == character) {
                // add basic animation to view
                let oldValue = Int(oldCharacter ?? "") ?? 0
                let newValue = Int(character) ?? 0
                // jump from 9 to 0 should be animated in the correct direction
                if oldValue == 9 && newValue != 8 {
                    let direction = isOneDirection ? oneScrollDirection: TickerLabelScrollDirection.down
                    self.addLabelAnimation(characterView, direction: direction)
                } else if (oldValue == 0 || oldValue == 1) && newValue == 9 {
                    let direction = isOneDirection ? oneScrollDirection:TickerLabelScrollDirection.up
                    self.addLabelAnimation(characterView, direction: direction)
                } else if oldValue > newValue {
                    let direction = isOneDirection ? oneScrollDirection:TickerLabelScrollDirection.up
                    self.addLabelAnimation(characterView, direction: direction)
                } else if oldValue < newValue {
                    let direction = isOneDirection ? oneScrollDirection:TickerLabelScrollDirection.down
                    self.addLabelAnimation(characterView, direction: direction)
                } else {
                    let direction = isOneDirection ? oneScrollDirection:TickerLabelScrollDirection.down
                    self.addLabelAnimation(characterView, direction: direction)
                }
            }
        }

        self.text = text
    }
    
    // MARK: - Character Animation
    func addLabelAnimation(_ label: UILabel, direction scrollDirection: TickerLabelScrollDirection) {
        _ = addLabelAnimation(label, direction: scrollDirection, notifyDelegate: false)
    }
    
    func addLabelAnimation(_ label: UILabel, direction aScrollDirection: TickerLabelScrollDirection, notifyDelegate: Bool) -> CATransition {
        var scrollDirection = aScrollDirection
        // inverse the scrolldirection, if the direction is going up
        if self.scrollDirection == TickerLabelScrollDirection.up {
            scrollDirection = aScrollDirection == .up ? .up : .down
        }
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = CFTimeInterval(animationDuration)
        transition.type = kCATransitionPush
        transition.subtype = scrollDirection == TickerLabelScrollDirection.up ? kCATransitionFromTop : kCATransitionFromBottom
        if notifyDelegate {
            transition.delegate = label as? CAAnimationDelegate
        }
        label.layer.add(transition, forKey: nil)
        return transition
    }

    // MARK: - Character Labels
    func insertNewCharacterLabel() {
        var characterFrame: CGRect = CGRect.zero
        characterFrame.size = CGSize(width: characterWidth, height: bounds.size.height)
        let characterLabel = TickerCharacterLabel(frame: characterFrame)
        characterLabel.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        characterLabel.textAlignment = .center
        if characterViews.count == 0 {
            characterLabel.font = currencySymbolFont
        } else {
            characterLabel.font = font
        }
        characterLabel.textColor = textColor
        characterLabel.shadowColor = shadowColor
        characterLabel.shadowOffset = shadowOffset
        charactersView.addSubview(characterLabel)
        characterViews.append(characterLabel)
    }
    
    func removeLastCharacterLabel(_ animated: Bool) {
        var label: TickerCharacterLabel?
        if textAlignment == .right {
            label = characterViews.first
        } else {
            label = characterViews.last
        }

        if label == nil {
            return
        }

        while let elementIndex = characterViews.index(of: label!) {
            characterViews.remove(at: elementIndex)
        }

        if animated {
            label?.text = nil
            if let aLabel = label {
                labelViewsToRemove.insert(aLabel)
                labelDidCompleteRemovealAnimation(aLabel)
            }
            weak var weakSelf = self
            label?.animationDidCompleteBlock = {(_ label: TickerCharacterLabel) -> Void in
                weakSelf?.labelDidCompleteRemovealAnimation(label)
            }
            _ = addLabelAnimation(label!, direction: TickerLabelScrollDirection.up, notifyDelegate: true)
        } else {
            label?.removeFromSuperview()
        }
    }
    
    func labelDidCompleteRemovealAnimation(_ label: TickerCharacterLabel) {
        label.removeFromSuperview()
        while let elementIndex = labelViewsToRemove.index(of: label) { labelViewsToRemove.remove(at: elementIndex) }
        if labelViewsToRemove.count == 0 {
            layoutCharacterLabels()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        if characterViews.count > 0 {
            charactersView.frame = characterViewFrame(withContentBounds: bounds)
        }
    }
    
    func characterViewFrame(withContentBounds aFrame: CGRect) -> CGRect {
        var frame = aFrame
        let charactersWidth: CGFloat = CGFloat(characterViews.count) * characterWidth
        frame.size.width = charactersWidth
        switch textAlignment {
        case .right:
            frame.origin.x = self.frame.size.width - charactersWidth
        case .center:
            frame.origin.x = (self.frame.size.width - charactersWidth) / 2
        case .left:
            fallthrough
        default:
            frame.origin.x = 0.0
        }
        return frame
    }
    
    func layoutCharacterLabels(text newText: String? = nil) {
        let text: String
        if newText == nil {
            text = self.text
        } else {
            text = newText!
        }

        var characterFrame: CGRect = CGRect.zero
        
        // Center charactersView
        var actualWidth: CGFloat = 0
        var charWidths: [CGFloat] = []
        for letter in text {
            let charWidth = String(letter).size(withAttributes: [NSAttributedStringKey.font: font]).width
            charWidths.append(charWidth)
            actualWidth += charWidth
        }
        characterFrame.origin.x = (CGFloat(characterViews.count) * characterWidth - actualWidth)*0.5
        
        for (index, label) in characterViews.enumerated() {
            characterFrame.size.height = charactersView.bounds.height
            // The first character is $ or ¥. The size is
            if index == 0 {
                let character: String = (text as NSString).substring(with: NSRange(location: 0, length: 1))
                let characterHeight = character.size(withAttributes: [NSAttributedStringKey.font: currencySymbolFont]).height
                // 0.4 is value we have to tune
                var factor: CGFloat = 0.4
                if character == "$" {
                    factor = 0.3
                } else if character == "¥" {
                    factor = 0.4
                }
                characterFrame.size.height = (charactersView.bounds.height-characterHeight)*factor + charactersView.bounds.height
            }
            
            let characterWidth: CGFloat
            if index >= charWidths.count {
                let text = label.text ?? "8"
                characterWidth = text.size(withAttributes: [NSAttributedStringKey.font: font]).width
            } else {
                characterWidth = charWidths[index]
            }

            characterFrame.size.width = characterWidth
            label.frame = characterFrame
            characterFrame.origin.x += characterWidth
        }
    }
    
    func intrinsicContentSize() -> CGSize {
        var width: CGFloat = 0
        for label: UILabel in characterViews {
            let text = label.text ?? "8"
            let characterWidth = text.size(withAttributes: [NSAttributedStringKey.font: font]).width
            width += characterWidth
        }
        return CGSize(width: width, height: UIViewNoIntrinsicMetric)
    }
    
    // MARK: - Text Appearance
    func setShadowOffset(_ shadowOffset: CGSize) {
        self.shadowOffset = shadowOffset
        for characterView in characterViews {
            characterView.shadowOffset = shadowOffset
        }
    }
    
    func setShadowColor(_ shadowColor: UIColor) {
        self.shadowColor = shadowColor
        for characterView in characterViews {
            characterView.shadowColor = shadowColor
        }
    }
    
    func setTextColor(_ textColor: UIColor) {
        if !(self.textColor == textColor) {
            self.textColor = textColor
            for characterView in characterViews {
                characterView.textColor = textColor
            }
        }
    }
    
    // When call setFont, the characterViews is empty.
    func setFont(_ font: UIFont, currencySymbolFont: UIFont) {
        self.font = font
        self.currencySymbolFont = currencySymbolFont
        characterWidth = "8".size(withAttributes: [NSAttributedStringKey.font: font]).width
        for characterView in characterViews {
            characterView.font = font
        }
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    func setTextAlignment(_ textAlignment: NSTextAlignment) {
        self.textAlignment = textAlignment
        setNeedsLayout()
    }

}
