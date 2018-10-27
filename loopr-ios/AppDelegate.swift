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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let splashImageView = SplashImageView(frame: .zero)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self, Answers.self])
        
        // Fetch data in the background fetch mode.
        UIApplication.shared.setMinimumBackgroundFetchInterval(10)
        
        FontConfigManager.shared.setup()
        
        Themes.restoreLastTheme()
        updateTheme()
        ThemeManager.animationDuration = 1.0
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumSize(CGSize(width: 240, height: 120))
        
        let initialViewController = MainTabController(nibName: nil, bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        // Note: Don't change the following sequence of setup
        AppWalletDataManager.shared.setup()
        CurrentAppWalletDataManager.shared.setup()
        if AppWalletDataManager.shared.getWallets().isEmpty {
            self.window?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        }

        // Get the estimate gas price when launching the app.
        GasDataManager.shared.getEstimateGasPrice { (_, _) in }

        PriceDataManager.shared.startGetPriceQuote()
        MarketDataManager.shared.startGetTicker()
        LoopringAPIRequest.getTicker(by: .coinmarketcap) { (markets, error) in
            print("AppDelegate receive LoopringAPIRequest.getMarkets")
            if error == nil {
                MarketDataManager.shared.setMarkets(newMarkets: markets)
            }
        }

        PartnerDataManager.shared.createPartner()
        PartnerDataManager.shared.activatePartner()

        _ = SettingDataManager.shared.getCurrentLanguage()

        // manager?.startListening()
        SettingsBundleHelper.setVersionAndBuildNumber()
        
        // Touch ID and Face ID
        if AuthenticationDataManager.shared.getPasscodeSetting() && !AuthenticationDataManager.shared.hasLogin {
            AuthenticationDataManager.shared.hasLogin = true
            let authenticationViewController: AuthenticationViewController? = AuthenticationViewController(nibName: nil, bundle: nil)
            authenticationViewController?.needNavigate = true
            self.window?.rootViewController = authenticationViewController
        }

        splashImageView.tag = 1234
        splashImageView.image = UIImage(named: "Splash\(ColorTheme.getTheme())")
        splashImageView.contentMode = .scaleAspectFill
        splashImageView.frame = self.window!.frame
        self.window?.addSubview(splashImageView)
        self.window?.bringSubview(toFront: splashImageView)
        
        // Used in vivwallet 0.9.10
        // PushNotificationDeviceDataManager.shared.testAPI()

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
        let banner = NotificationBanner.generate(title: "No network", style: .warning)
        banner.duration = 5.0
        banner.show()
    }
    
    func updateTheme() {
        // Setup color in the app.
        // Avoid dark shadow on navigation bar during segue transition
        self.window?.theme_backgroundColor = ColorPicker.backgroundColor
        
        // table cell background color.
        let colorView = UIView(frame: .zero)
        colorView.theme_backgroundColor = ColorPicker.cardHighLightColor
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // status bar
        UIApplication.shared.theme_setStatusBarStyle([.lightContent, .lightContent], animated: true)
        
        // navigation bar
        let navigationBar = UINavigationBar.appearance()

        navigationBar.isTranslucent = false
        navigationBar.theme_tintColor = GlobalPicker.barTextColor
        navigationBar.theme_barTintColor = ColorPicker.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(GlobalPicker.titleAttributes)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        // For some reason, SplashImageView doesn't work here. SplashImageView is to used to avoid SVProgress and backgroundImage shows up at the same time.
        
        if !AuthenticationDataManager.shared.isAuthenticating {
            let backgroundImageView = UIImageView(frame: .zero)
            backgroundImageView.tag = 2345
            backgroundImageView.image = UIImage(named: "Splash\(ColorTheme.getTheme())")
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.frame = self.window!.frame
            self.window?.addSubview(backgroundImageView)
            self.window?.bringSubview(toFront: backgroundImageView)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
        AuthenticationDataManager.shared.hasLogin = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")

        // We may need to change this when we implement more push notification related features.
        // Get nonce from eth, not relay. Cost time maybe.
        CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.getNonceFromEthereum(completionHandler: {})

        // Touch ID and Face ID
        if AuthenticationDataManager.shared.getPasscodeSetting() && !AuthenticationDataManager.shared.hasLogin {
            let authenticationViewController: AuthenticationViewController? = AuthenticationViewController(nibName: nil, bundle: nil)
            if let rootViewController = self.window?.rootViewController {
                rootViewController.present(authenticationViewController!, animated: true) {}
            }
        }
        
        // Remove backgrond image
        if let splashImageView = self.window?.viewWithTag(1234) as? SplashImageView {
            if !splashImageView.isUIViewAnimating {
                splashImageView.isUIViewAnimating = true
                // The duration here is supported to be shorten than the value in WalletViewController.
                let duration: TimeInterval
                let delay: TimeInterval
                if AppWalletDataManager.shared.getWallets().isEmpty {
                    duration = 0.5
                    delay = 2
                } else {
                    duration = 0.5
                    delay = 0.1
                }
                UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: { () -> Void in
                    splashImageView.alpha = 0
                }, completion: { _ in
                    splashImageView.isUIViewAnimating = false
                    splashImageView.removeFromSuperview()
                })
            }
        }
        
        // Remove backgrond image
        if let backgroundView = self.window?.viewWithTag(2345) {
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: { () -> Void in
                backgroundView.alpha = 0
            }, completion: { _ in
                backgroundView.removeFromSuperview()
            })
        }
        
        // Clear the push notification badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AuthenticationDataManager.shared.hasLogin = false
        CoreDataManager.shared.saveContext()
    }

    // Push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Answers.logCustomEvent(withName: "didRegisterForRemoteNotificationsWithDeviceToken v1",
                               customAttributes: [:])

        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        PushNotificationDeviceDataManager.shared.setDeviceToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
        Answers.logCustomEvent(withName: "didFailToRegisterForRemoteNotificationsWithError v1",
                               customAttributes: [
                               "error": error.localizedDescription])
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Answers.logCustomEvent(withName: "application performFetchWithCompletionHandler v1",
                               customAttributes: [:])

        print("hello world.")
        // Example:
        LocalNotificationManager.shared.publishNotification()

        completionHandler(.newData)
    }

}
