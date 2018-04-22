//
//  AppDelegate.swift
//  loopr-ios
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import SwiftTheme
import NotificationBannerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FontConfigManager.shared.setup()

        AppWalletDataManager.shared.setup()
        CurrentAppWalletDataManager.shared.setup()

        if AppWalletDataManager.shared.getWallets().isEmpty {
            self.window?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        }
        
        Themes.restoreLastTheme()
        ThemeManager.animationDuration = 1.0
        
        // TODO: check whether it is properly: socket.io must be established befor startxxx method
        LoopringSocketIORequest.setup()
        PriceQuoteDataManager.shared.startGetPriceQuote()
        MarketDataManager.shared.startGetTicker()
        
        _ = SettingDataManager.shared.getCurrentLanguage()

        updateTheme()
        
        let manager = NetworkingReachabilityManager.shared
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
            if status == NetworkReachabilityStatus.notReachable || status == NetworkReachabilityStatus.unknown {
                self.showNetworkLossBanner()
            }
        }
        
        // manager?.startListening()

        return true
    }
    
    func showNetworkLossBanner() {
        let notificationTitle = NSLocalizedString("Sorry, network is lost. Please make sure the internet connection is stable", comment: "")
        let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
        let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
        let banner = NotificationBanner(attributedTitle: attributeString, style: .warning, colors: NotificationBannerStyle())
        banner.duration = 2.0
        banner.show()
    }
    
    func updateTheme() {
        // Setup color in the app.
        self.window?.backgroundColor = UIColor.white
        
        // table cell background color.
        let colorView = UIView()
        colorView.backgroundColor = UIStyleConfig.tableCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // status bar
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent, .lightContent, .lightContent], animated: true)
        
        // navigation bar
        let navigationBar = UINavigationBar.appearance()
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)!,
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
        let manager = NetworkingReachabilityManager.shared
        if manager?.isReachable == false {
            self.showNetworkLossBanner()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let manager = NetworkingReachabilityManager.shared
        if manager?.isReachable == false {
            self.showNetworkLossBanner()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NetworkingReachabilityManager.shared?.stopListening()
    }

}
