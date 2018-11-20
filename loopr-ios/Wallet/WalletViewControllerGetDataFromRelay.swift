//
//  WalletViewControllerGetDataFromRelay.swift
//  loopr-ios
//
//  Created by xiaoruby on 11/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import SVProgressHUD

extension WalletViewController {

    // This part of code is complicated. App has to send several API requests to launch.
    func getDataFromRelay() {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        
        // isLaunching is true at any of the following situations:
        // 1. Launch app
        // 2. Create wallet
        // 3. Import wallet
        // 4. Switch the current wallet.
        if self.isLaunching {
            // Remove backgrond image if it exists
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            if let splashImageView = appDelegate?.window?.viewWithTag(1234) as? SplashImageView {
                if !splashImageView.isUIViewAnimating {
                    splashImageView.isUIViewAnimating = true
                    UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseIn, animations: { () -> Void in
                        splashImageView.alpha = 0
                    }, completion: { _ in
                        splashImageView.isUIViewAnimating = false
                        splashImageView.removeFromSuperview()
                        if self.isLaunching {
                            SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
                        }
                    })
                } else {
                    // Disable user touch when loading data
                    SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
                }
            } else {
                // Disable user touch when loading data
                SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
            }
        }
        
        let dispatchGroup = DispatchGroup()
        
        // tokens.json contains 67 tokens.
        if TokenDataManager.shared.getTokens().count < 70 {
            dispatchGroup.enter()
            TokenDataManager.shared.loadCustomTokensForCurrentWallet(completionHandler: {
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.enter()
        CurrentAppWalletDataManager.shared.getBalanceAndPriceQuoteAndNonce(getPrice: true, completionHandler: { _, error in
            print("receive CurrentAppWalletDataManager.shared.getBalanceAndPriceQuote() in WalletViewController")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let banner = NotificationBanner.generate(title: "Sorry. Network error", style: .info)
                banner.duration = 2.0
                banner.show()
                self.refreshControl.endRefreshing()
                return
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            if self.isLaunching {
                self.isLaunching = false
                
                // Then get all balance. It takes times.
                AppWalletDataManager.shared.getAllBalanceFromRelayInBackgroundThread()
                // Setup socket io at the end of the launch
                LoopringSocketIORequest.setup()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    SVProgressHUD.dismiss()
                    
                    // Ask for permission
                    PushNotificationSettingManager.shared.registerForPushNotifications()
                    
                    // Check app version
                    AppServiceUpdateManager.shared.getLatestAppVersion(completion: {(shouldDisplayUpdateNotification) in
                        if shouldDisplayUpdateNotification {
                            self.displayUpdateNotification()
                        }
                    })
                    
                    // Get user config
                    AppServiceUserManager.shared.getUserConfig(completion: { (config, _) in
                        if let config = config {
                            let configuration = JSON.init(parseJSON: config.rawString()!)
                            
                            // Updating language or currency will trigger a sequence of API requests.
                            if SettingDataManager.shared.getCurrentLanguage().name != configuration["language"].stringValue {
                                _ = SetLanguage(configuration["language"].stringValue)
                            }
                            
                            if SettingDataManager.shared.getCurrentCurrency().name != configuration["currency"].stringValue {
                                let currency = Currency(name: configuration["currency"].stringValue)
                                print("receive: " + currency.name)
                                SettingDataManager.shared.setCurrentCurrency(currency)
                                NotificationCenter.default.post(name: .needRelaunchCurrentAppWallet, object: nil)
                            }
                        }
                    })
                }
                
                self.processPasteboard()
            }
            self.assetTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
}
