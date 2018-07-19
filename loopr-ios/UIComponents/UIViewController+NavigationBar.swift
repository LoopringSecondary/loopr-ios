//
//  UIViewController+NavigationBar.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import SwiftTheme

extension UIViewController {
    
    // Used in viewWillAppear()
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // Used in viewDidDisappear()
    func showNavigationBar() {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        let titleAttributes = GlobalPicker.navigationBarTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.font: FontConfigManager.shared.getNavigationTitleFont(),
                NSAttributedStringKey.shadow: shadow
            ]
        }
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.theme_tintColor = GlobalPicker.navigationBarTextColor
        self.navigationController?.navigationBar.theme_barTintColor = GlobalPicker.navigationBarTintColor
        self.navigationController?.navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        
    }
}

