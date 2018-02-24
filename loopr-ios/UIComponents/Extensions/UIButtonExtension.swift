//
//  UIButtonExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {
    
    var title: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
    
    var titleColor: UIColor? {
        get { return titleColor(for: .normal) }
        set { setTitleColor(newValue, for: .normal) }
    }
    
    var image: UIImage? {
        get { return image(for: .normal) }
        set { setImage(newValue, for: .normal) }
    }
    
    var backgroundImage: UIImage? {
        get { return backgroundImage(for: .normal) }
        set { setBackgroundImage(newValue, for: .normal) }
    }
    
}
