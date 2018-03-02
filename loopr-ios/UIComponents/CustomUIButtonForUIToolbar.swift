//
//  CustomUIButtonForUIToolbar.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class CustomUIButtonForUIToolbar: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // self.layer.borderColor = UIColor.blue.cgColor
        // self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        // self.setTitleColor(UIColor.blue, for: .normal)
        // self.setTitleColor(UIColor.white, for: .highlighted)
        
        self.tintColor = UIStyleConfig.defaultTintColor
    }
    
    func selected() {
        self.backgroundColor = UIStyleConfig.defaultTintColor
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    func unselected() {
        self.backgroundColor = UIColor.clear
        self.setTitleColor(self.tintColor, for: .normal)
    }

}
