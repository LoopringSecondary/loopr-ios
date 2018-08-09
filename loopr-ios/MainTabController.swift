//
//  MainTabController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class MainTabController: ESTabBarController {
    
    var viewController1: UIViewController!
    var viewController2: UIViewController!
    var viewController3: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = Themes.isDark() ? .dark3 : .white
        
        // Asset view controller
        viewController1 = WalletNavigationViewController()
        viewController1.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Assets"), selectedImage: UIImage(named: "Assets-selected"))
        
        // Trade view controller
        viewController2 = TradeSelectionNavigationViewController()
        viewController2.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Trade"), selectedImage: UIImage(named: "Trade-selected"))
        
        // Setting view controller
        let viewController3 = SettingNavigationViewController()
        viewController3.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Settings"), selectedImage: UIImage(named: "Settings-selected"))
        
        viewControllers = [viewController1, viewController2, viewController3]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func processExternalUrl() {
        if let vc = viewController1 as? WalletNavigationViewController {
            vc.processExternalUrl()
        }
    }
}
