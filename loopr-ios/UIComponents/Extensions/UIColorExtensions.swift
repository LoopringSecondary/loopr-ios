//
//  UIColorExtensions.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func convert(to color: UIColor, multiplier _multiplier: CGFloat) -> UIColor? {
        let multiplier = min(max(_multiplier, 0), 1)
        let components = cgColor.components ?? []
        let toComponents = color.cgColor.components ?? []
        if components.isEmpty || components.count < 3 || toComponents.isEmpty || toComponents.count < 3 {
            return nil
        }
        var results: [CGFloat] = []
        for index in 0...3 {
            let result = (toComponents[index] - components[index]) * abs(multiplier) + components[index]
            results.append(result)
        }
        return UIColor(red: results[0], green: results[1], blue: results[2], alpha: results[3])
    }
    
    class var buttonBackground: UIColor {
        return UIColor(named: "ButtonBackground")!
    }
    
    class var primary: [UIColor] {
        return [UIColor.init(rgba: "#02DDB6"), UIColor.init(rgba: "#01B97F")]
    }
    
    class var primaryHighlight: [UIColor] {
        return [UIColor.init(rgba: "#3CBA92"), UIColor.init(rgba: "#0BA360")]
    }
    
    class var secondary: [UIColor] {
        return [UIColor.init(rgba: "#CE4CE6"), UIColor.init(rgba: "#FA4A6F")]
    }
    
    class var secondaryHighlight: [UIColor] {
        return [UIColor.init(rgba: "#CF2549"), UIColor.init(rgba: "#8C1CA0")]
    }
    
    // #F5F5F5
    class var mute: UIColor {
        return UIColor(named: "Color-mute")!
    }
    
    // #222222
    class var dark1: UIColor {
        return UIColor(named: "Color-dark1")!
    }
    
    // #292929
    class var dark2: UIColor {
        return UIColor(named: "Color-dark2")!
    }
    
    // #383838
    class var dark3: UIColor {
        return UIColor(named: "Color-dark3")!
    }
    
    // #666666
    class var dark4: UIColor {
        return UIColor(named: "Color-dark4")!
    }
    
    // #888888
    class var dark5: UIColor {
        return UIColor(named: "Color-dark5")!
    }
    
    class var up: UIColor {
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" {
            return UIColor(named: "Color-green")! // #01B97F
        } else {
            return UIColor(named: "Color-red")!   // #FA4A6F
        }
    }
    
    class var down: UIColor {
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" {
            return UIColor(named: "Color-red")!   // #FA4A6F
        } else {
            return UIColor(named: "Color-green")! // #01B97F
        }
    }
}
