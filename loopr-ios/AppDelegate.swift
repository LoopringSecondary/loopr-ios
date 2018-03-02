//
//  AppDelegate.swift
//  loopr-ios
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftTheme

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Themes.restoreLastTheme()
        ThemeManager.animationDuration = 1.0
        
        // Generate mock data
        AssetDataManager.shared.generateMockData()
        WalletDataManager.shared.generateMockData()
        
        // Get data from Relay
        OrderDataManager.shared.getOrdersFromServer()
        MarketDataManager.shared.getMarketsFromServer { (_, _) in
            
        }
        
        // Setup color in the app.
        self.window?.backgroundColor = UIColor.white
        
        let colorView = UIView()
        colorView.backgroundColor = UIStyleConfig.tableCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = colorView

        // UITabBar.appearance().tintColor = UIStyleConfig.tabBarTintColor
        
        // The following code is to hide the bottom line of the navigation bar.
        // It's not easy to implement in iPhone x and other models. It also breaks
        // UIAlertController animation.
        // It's resolved by adding an empty image to the shadow.
        
        // Hide the bottom line in the navigation bar.
        // UINavigationBar.appearance().shadowImage = UIImage()
        // UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // Set unsafe area background color for iPhone X
        // UIApplication.shared.statusBarView?.backgroundColor = UIColor(white: 1, alpha: 1)
        
        updateTheme()
        return true
    }
    
    func updateTheme() {
        // status bar
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent, .lightContent, .lightContent], animated: true)
        
        // navigation bar
        let navigationBar = UINavigationBar.appearance()
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                NSAttributedStringKey.shadow: shadow
            ]
        }
        
        navigationBar.theme_tintColor = GlobalPicker.barTextColor
        navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        
        // tab bar
        let tabBar = UITabBar.appearance()
        
        tabBar.theme_tintColor = GlobalPicker.barTextColor
        tabBar.theme_barTintColor = GlobalPicker.barTintColor
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
