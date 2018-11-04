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
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    let splashImageView = SplashImageView(frame: .zero)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Fabric.with([Crashlytics.self, Answers.self])
        
        // Background Fetch doesn't work very well and consume a lot of battery.
        // Fetch data in the background fetch mode.
        // UIApplication.shared.setMinimumBackgroundFetchInterval(10)
        
        FontConfigManager.shared.setup()
        
        Themes.restoreLastTheme()
        updateTheme()
        ThemeManager.animationDuration = 1.0
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumSize(CGSize(width: 240, height: 120))
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = getRootViewController()

        // Note: Don't change the following sequence of setup
        AppWalletDataManager.shared.setup()
        CurrentAppWalletDataManager.shared.setup()

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
        
        if hasKeysPlist() {
            print("Found keys.plist")
            WXApi.registerApp(getWechatAppId()!)
        }

        return true
    }
    
    func getRootViewController() -> UIViewController {
        var result: UIViewController
        if Production.getCurrent() == .upwallet {
            if UserDefaults.standard.string(forKey: "openid") != nil && hasKeysPlist() {
                if AppWalletDataManager.shared.getWallets().isEmpty {
                    result = SetupNavigationController(nibName: nil, bundle: nil)
                } else {
                    result = MainTabController(nibName: nil, bundle: nil)
                }
            } else {
                result = ThirdPartyViewController(nibName: nil, bundle: nil)
            }
        } else {
            if AppWalletDataManager.shared.getWallets().isEmpty {
                result = SetupNavigationController(nibName: nil, bundle: nil)
            } else {
                result = MainTabController(nibName: nil, bundle: nil)
            }
        }
        return result
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if hasKeysPlist() && url.scheme == getWechatAppId()! {
            WXApi.handleOpen(url, delegate: self)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if hasKeysPlist() && url.scheme == getWechatAppId()! {
            WXApi.handleOpen(url, delegate: self)
        }
        return true
    }
    
    func application(app: UIApplication, openURL url: URL, options: [String: AnyObject]) -> Bool {
        if hasKeysPlist() && url.scheme == getWechatAppId()! {
            return WXApi.handleOpen(url, delegate: self)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == nil {
            return true
        }
        if hasKeysPlist() && url.scheme == getWechatAppId()! {
            return WXApi.handleOpen(url, delegate: self)
        } else {
            let queryArray = url.absoluteString.components(separatedBy: "/")
            let unescaped = queryArray[2].removingPercentEncoding!
            AuthorizeDataManager.shared.process(qrContent: unescaped)
            if let main = self.window?.rootViewController as? MainTabController {
                main.processExternalUrl()
            }
        }
        return true
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
                NotificationCenter.default.post(name: .needCheckStringInPasteboard, object: nil)
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
    
    //  微信回调
    func onResp(_ resp: BaseResp!) {
        //  微信登录回调
        if resp.isKind(of: SendAuthResp.self) {
            let authResp = resp as! SendAuthResp
            if authResp.errCode == 0, let code = authResp.code, let appid = getWechatAppId(), let secret = getWechatAppSecret() {
                let parameters = ["appid": appid, "secret": secret, "code": code, "grant_type": "authorization_code"]
                Request.get("https://api.weixin.qq.com/sns/oauth2/access_token", parameters: parameters) { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    let json = JSON(data)
                    let accessToken = json["access_token"].stringValue
                    let openID = json["openid"].stringValue
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    UserDefaults.standard.set(openID, forKey: "openid")
                    UserDefaults.standard.synchronize()
                    self.wechatLoginByRequestForUserInfo()
                }
            }
        }
    }
    
    func wechatLoginByRequestForUserInfo() {
        let accessToken = UserDefaults.standard.string(forKey: "access_token")
        let openID = UserDefaults.standard.string(forKey: "openid")
        // 获取用户信息
        let parameters = ["access_token": accessToken!, "openid": openID!]
        Request.get("https://api.weixin.qq.com/sns/oauth2/access_token", parameters: parameters) { _, _, error in
            guard error == nil else { return }
            DispatchQueue.main.async {
                if AppWalletDataManager.shared.getWallets().isEmpty {
                    self.window?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
                } else {
                    self.window?.rootViewController = MainTabController(nibName: nil, bundle: nil)
                }
            }
        }
    }
    
    // Put keys.plist next to info.plist in Xcode.
    func hasKeysPlist() -> Bool {
        if Bundle.main.path(forResource: "keys", ofType: "plist") != nil {
            return true
        } else {
            return false
        }
    }
    
    func getWechatAppId() -> String? {
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let wechatAppId = dict["wechatAppId"] as? String
            return wechatAppId
        }
        return nil
    }

    func getWechatAppSecret() -> String? {
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let wechatAppId = dict["wechatAppSecret"] as? String
            return wechatAppId
        }
        return nil
    }

}
