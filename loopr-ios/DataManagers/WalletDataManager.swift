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

    private var currentWallet: Wallet?
    
    func getCurrentWallet() -> Wallet? {
        return currentWallet
    }
    
    func setCurrentWallet(_ wallet: Wallet) {
        currentWallet = wallet
    }
    
    func getWallets() -> [Wallet] {
        return wallets
    }

    func generateMockData() {
        let wallet1 = Wallet(address: "#1234567890qwertyuiop1", name: "Wallet 1", active: true)
        let wallet2 = Wallet(address: "#1234567890qwertyuiop2", name: "Wallet 2", active: true)
        let wallet3 = Wallet(address: "#1234567890qwertyuiop3", name: "Wallet 3", active: true)

        wallets = [wallet1, wallet2, wallet3]
        setCurrentWallet(wallet1)
    }
}
