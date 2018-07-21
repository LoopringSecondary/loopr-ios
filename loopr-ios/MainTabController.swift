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
        
        self.tabBar.barTintColor = Themes.isDark() ? .dark3 : .white
        
        // Do any additional setup after loading the view.
        let v1 = WalletNavigationViewController()
        
        let newTradeNavigationViewController = UINavigationController()
        let tradeSelectionViewController = TradeSelectionViewController()
        newTradeNavigationViewController.navigationBar.shadowImage = UIImage()
        newTradeNavigationViewController.setViewControllers([tradeSelectionViewController], animated: false)
        newTradeNavigationViewController.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Trade"), selectedImage: UIImage(named: "Trade-selected"))
        
        let v2 = MarketNavigationViewController()
        let v3 = TradeNavigationViewController()
        let v4 = SettingNavigationViewController()
        
        v1.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Assets"), selectedImage: UIImage(named: "Assets-selected"))
        v2.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Trade"), selectedImage: UIImage(named: "Trade-selected"))
        v3.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Trade"), selectedImage: UIImage(named: "Trade-selected"))
        v4.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(), title: nil, image: UIImage(named: "Settings"), selectedImage: UIImage(named: "Settings-selected"))
        viewControllers = [v1, newTradeNavigationViewController, v2, v3, v4]
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
