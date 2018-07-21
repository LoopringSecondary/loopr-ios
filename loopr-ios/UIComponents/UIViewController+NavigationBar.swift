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
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.theme_tintColor = GlobalPicker.textColor
        self.navigationController?.navigationBar.theme_barTintColor = GlobalPicker.backgroundColor
        self.navigationController?.navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(GlobalPicker.titleAttributes)
    }
}
