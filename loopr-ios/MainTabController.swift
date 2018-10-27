//
//  MainTabController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import UserNotifications

class MainTabController: ESTabBarController, UNUserNotificationCenterDelegate {
    
    var viewController1: UIViewController!
    var viewController2: UIViewController!
    var viewController3: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = Themes.isDark() ? .dark2 : .white
        
        // Asset view controller
        viewController1 = WalletNavigationViewController()

        // Trade view controller
        viewController2 = TradeSelectionNavigationViewController()

        // Setting view controller
        viewController3 = SettingNavigationViewController()

        setTabBarItems()        
        viewControllers = [viewController1, viewController2, viewController3]
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChangedReceivedNotification), name: .languageChanged, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(localNotificationReceived), name: .publishLocalNotificationToMainTabController, object: nil)

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
        
        // Example:
        LocalNotificationManager.shared.publishNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTabBarItems() {
        viewController1.tabBarItem = ESTabBarItem(TabBarItemBouncesContentView(frame: .zero), title: LocalizedString("Wallet", comment: ""), image: UIImage(named: "Assets"), selectedImage: UIImage(named: "Assets-selected" + ColorTheme.getTheme()))
        viewController2.tabBarItem = ESTabBarItem.init(TabBarItemBouncesContentView(frame: .zero), title: LocalizedString("Trade", comment: ""), image: UIImage(named: "Trade"), selectedImage: UIImage(named: "Trade-selected" + ColorTheme.getTheme()))
        viewController3.tabBarItem = ESTabBarItem(TabBarItemBouncesContentView(frame: .zero), title: LocalizedString("Settings", comment: ""), image: UIImage(named: "Settings"), selectedImage: UIImage(named: "Settings-selected" + ColorTheme.getTheme()))
    }
    
    @objc func languageChangedReceivedNotification() {
        setTabBarItems()
    }
    
    func processExternalUrl() {
        if let vc = viewController1 as? WalletNavigationViewController {
            vc.processExternalUrl()
        }
    }
    
}

// Local Notification
extension MainTabController {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    @objc func localNotificationReceived() {
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Hey this is Simplified iOS"
        content.body = "We are learning about iOS Local Notification"
        content.badge = 1
        
        UNUserNotificationCenter.current().delegate = self
        
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "leaf.prod.app", content: content, trigger: trigger)
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error)
        }
    }
}
