//
//  UISearchBarExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    var textColor:UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.textColor = newValue
            }
        }
    }
}
