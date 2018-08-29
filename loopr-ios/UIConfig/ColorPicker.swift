//
//  ColorPicker.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import SwiftTheme
import UIKit

class ColorPicker {
    
    class var backgroundColor: ThemeColorPicker {
        switch ColorTheme.current {
        case .red:
            return ["#f5f5f5", "#222222"]
        case .yellow:
            return ["#f5f5f5", "#16162A"]
        case .green:
            return ["#f5f5f5", "#222222"]
        case .blue:
            return ["#f5f5f5", "#222222"]
        }
        
    }

    class var cardBackgroundColor: ThemeColorPicker {
        switch ColorTheme.current {
        case .red:
            return ["#f5f5f5", "#292929"]
        case .yellow:
            return ["#f5f5f5", "#21203A"]
        case .green:
            return ["#f5f5f5", "#292929"]
        case .blue:
            return ["#f5f5f5", "#292929"]
        }
    }
    
    class var cardHighLightColor: ThemeColorPicker {
        switch ColorTheme.current {
        case .red:
            return ["#00000099", "#383838"]
        case .yellow:
            return ["#00000099", "#2B2C47"]
        case .green:
            return ["#00000099", "#383838"]
        case .blue:
            return ["#00000099", "#383838"]
        }
    }
    
    class var barTintColor: ThemeColorPicker {
        switch ColorTheme.current {
        case .red:
            return ["#f5f5f5", "#222222"]
        case .yellow:
            return ["#f5f5f5", "#16162A"]
        case .green:
            return ["#f5f5f5", "#222222"]
        case .blue:
            return ["#f5f5f5", "#222222"]
        }
    }

    class var button: ThemeImagePicker {
        switch ColorTheme.current {
        case .red:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#292929")))
        case .yellow:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#21203A")))
        case .green:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#292929")))
        case .blue:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#292929")))
        }
    }

    class var buttonSelected: ThemeImagePicker {
        switch ColorTheme.current {
        case .red:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#666666")))
        case .yellow:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#2B2C47")))
        case .green:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#666666")))
        case .blue:
            return ThemeImagePicker(images: UIImage.getImage(from: UIColor.init(rgba: "#f5f5f5")), UIImage.getImage(from: UIColor.init(rgba: "#666666")))
        }
    }

    class var buttonHighlight: ThemeImagePicker {
        return ThemeImagePicker(images: UIImage(named: "Button-highlight" + ColorTheme.getTheme()) ?? UIImage(), UIImage(named: "Button-highlight" + ColorTheme.getTheme()) ?? UIImage())
    }

}
