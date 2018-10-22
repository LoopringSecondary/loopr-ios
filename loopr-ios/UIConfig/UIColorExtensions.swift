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
    
    // Red color theme and blue color theme are not used.
    class var primary: [UIColor] {
        switch ColorTheme.current {
        case .red:
            return [UIColor.init(rgba: "#5ED279"), UIColor.init(rgba: "#2AAE49")]
        case .yellow:
            // green color
            return [UIColor.init(rgba: "#5ED279"), UIColor.init(rgba: "#46C767")]
        case .green:
            // red color
            return [UIColor.init(rgba: "#DD5252"), UIColor.init(rgba: "#E84F47")]
        case .blue:
            return [UIColor.init(rgba: "#5ED279"), UIColor.init(rgba: "#2AAE49")]
        }
    }
    
    class var primaryHighlighted: [UIColor] {
        switch ColorTheme.current {
        case .red:
            return [UIColor.init(rgba: "#5ED279"), UIColor.init(rgba: "#2AAE49")]
        case .yellow:
            // green color
            return [UIColor.init(rgba: "#3FBD5C"), UIColor.init(rgba: "#21A33F")]
        case .green:
            // red color
            return [UIColor.init(rgba: "#EC3D3D"), UIColor.init(rgba: "#D83931")]
        case .blue:
            return [UIColor.init(rgba: "#5ED279"), UIColor.init(rgba: "#2AAE49")]
        }
    }
    
    class var secondary: [UIColor] {
        switch ColorTheme.current {
        case .red:
            return [UIColor(rgba: "#CE4CE6"), UIColor(rgba: "#FA4A6F")]
        case .yellow:
            return [UIColor(rgba: "#EFC90C"), UIColor(rgba: "#FFB528")]
        case .green:
            return [UIColor(rgba: "#38B170"), UIColor(rgba: "#159763")]
        case .blue:
            return [UIColor(rgba: "#5ED279"), UIColor(rgba: "#2AAE49")]
        }
    }
    
    class var secondaryHighlighted: [UIColor] {
        switch ColorTheme.current {
        case .red:
            return [UIColor(rgba: "#CE4CE6"), UIColor(rgba: "#FA4A6F")]
        case .yellow:
            return [UIColor(rgba: "#F8BE1C"), UIColor(rgba: "#FFA928")]
        case .green:
            return [UIColor(rgba: "#159763"), UIColor(rgba: "#00965E")]
        case .blue:
            return [UIColor(rgba: "#5ED279"), UIColor(rgba: "#2AAE49")]
        }
    }
    
    // #F5F5F5
    class var mute: UIColor {
        return UIColor(named: "Color-mute")!
    }
    
    class var dark1: UIColor {
        switch ColorTheme.current {
        case .red:
            // #222222
            return UIColor(named: "Color-dark1")!
        case .yellow:
            return UIColor(rgba: "#16162A")
        case .green:
            // #222222
            return UIColor(named: "Color-dark1")!
        case .blue:
            return UIColor(named: "Color-dark1")!
        }
    }
    
    class var dark2: UIColor {
        switch ColorTheme.current {
        case .red:
            // #292929
            return UIColor(named: "Color-dark2")!
        case .yellow:
            return UIColor(rgba: "#21203A")
        case .green:
            // #292929
            return UIColor(named: "Color-dark2")!
        case .blue:
            return UIColor(named: "Color-dark2")!
        }
    }

    class var dark3: UIColor {
        switch ColorTheme.current {
        case .red:
            // #383838
            return UIColor(named: "Color-dark3")!
        case .yellow:
            return UIColor(rgba: "#2B2C47")
        case .green:
            // #383838
            return UIColor(named: "Color-dark3")!
        case .blue:
            return UIColor(named: "Color-dark3")!
        }
    }
    
    class var dark4: UIColor {
        switch ColorTheme.current {
        case .red:
            // #666666
            return UIColor(named: "Color-dark4")!
        case .yellow:
            return UIColor(rgba: "#343653")
        case .green:
            // #666666
            return UIColor(named: "Color-dark4")!
        case .blue:
            // #666666
            return UIColor(named: "Color-dark4")!
        }
    }
    
    // #888888
    class var dark5: UIColor {
        return UIColor(named: "Color-dark5")!
    }
    
    class var theme: UIColor {
        switch ColorTheme.current {
        case .red:
            return UIColor(rgba: "#EF5395")
        case .yellow:
            return UIColor(rgba: "#FDAE25")
        case .green:
            return UIColor(rgba: "#38B170")
        case .blue:
            return UIColor(named: "Color-red")!
        }
    }
    
    // #ffffffcc
    class var text1: UIColor {
        return UIColor(named: "Color-text1")!
    }
    
    // ffffff66
    class var text2: UIColor {
        return UIColor(named: "Color-text2")!
    }
    
    // #E84F47
    class var fail: UIColor {
        return UIColor(named: "Color-red")!
    }
    
    // #FFB832
    class var warn: UIColor {
        return UIColor(named: "Color-yellow")!
    }

    // #46C767
    class var success: UIColor {
        return UIColor(named: "Color-green")!
    }
    
    // HongKong has the same color as Unite States.
    class var up: UIColor {
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" {
            return UIColor(named: "Color-green")! // #01B97F
        } else {
            return UIColor(named: "Color-red")!   // #FA4A6F
        }
    }
    
    class var down: UIColor {
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" {
            return UIColor(named: "Color-red")!   // #DD5252
        } else {
            return UIColor(named: "Color-green")! // #01B97F
        }
    }
    
    // FFB832
    class var pending: UIColor {
        return UIColor(named: "Color-yellow")!
    }
}
