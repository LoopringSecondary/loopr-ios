//
//  UIViewController+BackButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
    func setBackButtonAndUpdateTitle(customizedNavigationBar: UINavigationBar, title: String) {
        let backButton = UIButton(type: UIButtonType.custom)

        backButton.theme_setImage(GlobalPicker.backButton, forState: .normal)
        backButton.theme_setImage(GlobalPicker.backButtonHighlight, forState: .highlighted)
        
        // Default left padding is 20. It should be 12 in our design.
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -16, bottom: 0, right: 8)
        
        backButton.addTarget(self, action: #selector(pressedBackButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let backBarButton = UIBarButtonItem(customView: backButton)
        
        let navigationLeftItem = UINavigationItem()
        navigationLeftItem.leftBarButtonItem = backBarButton
        
        let navigationItem = UINavigationItem()
        navigationItem.title = title
        navigationItem.leftBarButtonItem = backBarButton
        customizedNavigationBar.setItems([navigationItem], animated: false)
        
        // Add swipe to go-back feature back which is a system default gesture
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setBackButton() {
        let backButton = UIButton(type: UIButtonType.custom)
        
        backButton.theme_setImage(GlobalPicker.backButton, forState: .normal)
        backButton.theme_setImage(GlobalPicker.backButtonHighlight, forState: .highlighted)
        
        // Default left padding is 20. It should be 12 in our design.
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -16, bottom: 0, right: 8)
        backButton.addTarget(self, action: #selector(pressedBackButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let backBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton

        // Add swipe to go-back feature back which is a system default gesture
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    @objc func pressedBackButton(_ button: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController == nil {
            return false
        }
        return self.navigationController!.viewControllers.count > 1 ? true : false
    }

}
