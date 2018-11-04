//
//  WalletViewControllerExtensionAppService.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

extension WalletViewController {
    
    func displayUpdateNotification() {
        let alert = UIAlertController(title: LocalizedString("A new version of app is ready to update", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("Skip_Update", comment: ""), style: .default, handler: { _ in
            AppServiceUpdateManager.shared.setLargestSkipBuildVersion()
            Answers.logCustomEvent(withName: "App Update Notification v1",
                                   customAttributes: [
                                    "update": "false"])
        }))
        alert.addAction(UIAlertAction(title: LocalizedString("Update", comment: ""), style: .default, handler: { _ in
            // Navigate to website
            if let url = URL(string: Production.getUrlText()) {
                UIApplication.shared.open(url)
            }
            AppServiceUpdateManager.shared.setLargestSkipBuildVersion()
            Answers.logCustomEvent(withName: "App Update Notification v1",
                                   customAttributes: [
                                    "update": "true"])
        }))

        self.present(alert, animated: true, completion: nil)
    }

}
