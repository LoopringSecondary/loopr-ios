//
//  WalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class WalletDataManager {
    
    static let shared = WalletDataManager()
    
    private var wallets: [Wallet]
    
    private init() {
        wallets = []
    }

}
