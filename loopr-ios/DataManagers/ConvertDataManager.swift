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
    
    func convert() {
        // TODO: Call Relay API
        maxAmount = 0.0
    }
    
    func getMaxAmount(symbol: String) -> Double {
        let assets = CurrentAppWalletDataManager.shared.getAssets()
        let filteredAssets = assets.filter { (asset) -> Bool in
            return asset.symbol.uppercased() == symbol
        }
        for asset in filteredAssets {
            maxAmount = asset.balance
        }
        return maxAmount
    }
    
    func getAsset(by symbol: String) -> Asset? {
        let assets = CurrentAppWalletDataManager.shared.getAssets()
        for case let asset in assets where asset.symbol.uppercased() == symbol {
            return asset
        }
        return nil
    }
    
    func setMaxAmount(_ maxAmount: Double) {
        self.maxAmount = maxAmount
    }

}
