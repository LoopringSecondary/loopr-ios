//
//  AlertForErrorExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
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
