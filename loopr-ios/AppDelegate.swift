//
//  AppDelegate.swift
//  loopr-ios
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import CoreData
import SwiftTheme
import NotificationBannerSwift
import SVProgressHUD
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        FontConfigManager.shared.setup()
        
        Themes.restoreLastTheme()
        updateTheme()
        ThemeManager.animationDuration = 1.0
        SVProgressHUD.setDefaultStyle(.dark)
        
        let initialViewController = MainTabController(nibName: nil, bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        AppWalletDataManager.shared.setup()
        CurrentAppWalletDataManager.shared.setup()
        if AppWalletDataManager.shared.getWallets().isEmpty {
            self.window?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        }

        // Get the estimate gas price when launching the app.
        GasDataManager.shared.getEstimateGasPrice { (_, _) in }
        
        LoopringSocketIORequest.setup()
        PriceDataManager.shared.startGetPriceQuote()
        MarketDataManager.shared.startGetTicker()
        
        OrderDataManager.shared.getOrdersFromServer { (_, _) in }
        
        _ = SettingDataManager.shared.getCurrentLanguage()

        let manager = NetworkingReachabilityManager.shared
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
            if status == NetworkReachabilityStatus.notReachable || status == NetworkReachabilityStatus.unknown {
                self.showNetworkLossBanner()
            }
        }
        // manager?.startListening()
        SettingsBundleHelper.setVersionAndBuildNumber()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == nil {
            return true
        }
        let queryArray = url.absoluteString.components(separatedBy: "/")
        let unescaped = queryArray[2].removingPercentEncoding!
        AuthorizeDataManager.shared.process(qrContent: unescaped)
        if let main = self.window?.rootViewController as? MainTabController {
            main.processExternalUrl()
        }
        return true
    }
    
    func showNetworkLossBanner() {
        let banner = NotificationBanner.generate(title: "Sorry, network is lost. Please make sure the internet connection is stable", style: .warning)
        banner.duration = 5.0
        banner.show()
    }
    
    func updateTheme() {
        // Setup color in the app.
        // Avoid dark shadow on navigation bar during segue transition
        self.window?.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // table cell background color.
        let colorView = UIView()
        colorView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // status bar
        UIApplication.shared.theme_setStatusBarStyle([.lightContent, .lightContent], animated: true)
        
        // navigation bar
        let navigationBar = UINavigationBar.appearance()

        navigationBar.isTranslucent = false
        navigationBar.theme_tintColor = GlobalPicker.barTextColor
        navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(GlobalPicker.titleAttributes)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
        AuthenticationDataManager.shared.hasLogin = false
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
        print("applicationDidBecomeActive")

        let manager = NetworkingReachabilityManager.shared
        if manager?.isReachable == false {
            self.showNetworkLossBanner()
        }

        // Touch ID and Face ID
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            let authenticationViewController: AuthenticationViewController? = AuthenticationViewController(nibName: nil, bundle: nil)
            if let rootViewController = self.window?.rootViewController {
                rootViewController.present(authenticationViewController!, animated: true) {}
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NetworkingReachabilityManager.shared?.stopListening()
        AuthenticationDataManager.shared.hasLogin = false
        CoreDataManager.shared.saveContext()
    }

}
