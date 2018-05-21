//
//  DefaultSliderDelegate.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import CoreGraphics

public protocol DefaultSliderDelegate: class {
    
    /// Called when the DefaultSlider values are changed
    ///
    /// - Parameters:
    ///   - slider: DefaultSlider
    ///   - minValue: minimum value
    ///   - maxValue: maximum value
    func defaultSlider(_ slider: DefaultSlider, didChange minValue: CGFloat, maxValue: CGFloat)
    
    /// Called when the user has started interacting with the DefaultSlider
    ///
    /// - Parameter slider: DefaultSlider
    func didStartTouches(in slider: DefaultSlider)
    
    /// Called when the user has finished interacting with the DefaultSlider
    ///
    /// - Parameter slider: DefaultSlider
    func didEndTouches(in slider: DefaultSlider)
    
    /// Called when the DefaultSlider values are changed. A return `String?` Value is displayed on the `minLabel`.
    ///
    /// - Parameters:
    ///   - slider: DefaultSlider
    ///   - minValue: minimum value
    /// - Returns: String to be replaced
    func defaultSlider(_ slider: DefaultSlider, stringForMinValue minValue: CGFloat) -> String?
    
    /// Called when the DefaultSlider values are changed. A return `String?` Value is displayed on the `maxLabel`.
    ///
    /// - Parameters:
    ///   - slider: DefaultSlider
    ///   - maxValue: maximum value
    /// - Returns: String to be replaced
    func defaultSlider(_ slider: DefaultSlider, stringForMaxValue: CGFloat) -> String?
}

// MARK: - Default implementation

public extension DefaultSliderDelegate {
    func defaultSlider(_ slider: DefaultSlider, didChange minValue: CGFloat, maxValue: CGFloat) {}
    func didStartTouches(in slider: DefaultSlider) {}
    func didEndTouches(in slider: DefaultSlider) {}
    func defaultSlider(_ slider: DefaultSlider, stringForMinValue minValue: CGFloat) -> String? { return nil }
    func defaultSlider(_ slider: DefaultSlider, stringForMaxValue maxValue: CGFloat) -> String? { return nil }
}
