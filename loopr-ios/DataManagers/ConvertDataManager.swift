//
//  ConvertDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class ConvertDataManager {
    
    static let shared = ConvertDataManager()
    
    var amount: Double
    
    private var maxAmount: Double = 0
    
    private init() {
        amount = 0.0
    }
    
    func clear() {
        amount = 0.0
    }

    func setup() {
        print("setup ConvertDataManager")
        
        // Get the available amount
        // Find ETH asset
        let assets = CurrentAppWalletDataManager.shared.getAssets()
        let filteredAssets = assets.filter { (asset) -> Bool in
            return asset.symbol == "ETH"
        }
        for ETHAsset in filteredAssets {
            maxAmount = ETHAsset.balance
        }
    }
    
    func convert() {
        // TODO: Call Relay API
        maxAmount = 0.0
    }
    
    func getMaxAmount() -> Double {
        return maxAmount
    }
    
    func setMaxAmount(_ maxAmount: Double) {
        self.maxAmount = maxAmount
    }

}
