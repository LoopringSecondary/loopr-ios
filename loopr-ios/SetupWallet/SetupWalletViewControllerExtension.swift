//
//  AlertForErrorExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

extension UIViewController {

    func succeedAndExit(setupWalletMethod: QRCodeMethod) {
        Answers.logSignUp(withMethod: setupWalletMethod.description, success: true, customAttributes: nil)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = MainTabController.instantiate()
    }
    
    func alertForDuplicatedAddress() {
        let alert = UIAlertController(title: LocalizedString("Failed to import address. The device has imported the address already.", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func alertForError() {
        let alert = UIAlertController(title: LocalizedString("Failed to import address.", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }

}
