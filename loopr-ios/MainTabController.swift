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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let v1 = WalletNavigationViewController()
        let v2 = MarketNavigationViewController()
        let v3 = TradeNavigationViewController()
        let v4 = SettingNavigationViewController()
        let v5 = H5DexNavigationController()
        
        v1.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: NSLocalizedString("Wallet", comment: ""), image: UIImage(named: "Assets"))
        v2.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: NSLocalizedString("Market", comment: ""), image: UIImage(named: "Market"))
        v3.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: NSLocalizedString("Trade", comment: ""), image: UIImage(named: "Trade"))
        let settingTabItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: NSLocalizedString("Settings", comment: ""), image: UIImage(named: "Settings"))
        settingTabItem.contentView?.imageView.contentMode = .center
        v4.tabBarItem = settingTabItem
        v5.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: NSLocalizedString("Market", comment: ""), image: UIImage(named: "Market"))

        viewControllers = [v1, v2, v3, v4, v5]
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

}
