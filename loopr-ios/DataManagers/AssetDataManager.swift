//
//  AssetDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

class AssetDataManager {

    static let shared = AssetDataManager()
    
    private var assets: [Asset]
    
    private init() {
        assets = []
    }
    
    func getAssets() -> [Asset] {
        return assets
    }
    
    func exchange(at sourceIndex: Int, to destinationIndex: Int) {
        if destinationIndex < assets.count && sourceIndex < assets.count {
            assets.swapAt(sourceIndex, destinationIndex)
        }
    }
    
    func generateMockData() {
        assets = []

        let asset1 = Asset(symbol: "ETH", name: "Ethereum", icon: UIImage(named: "ETH")!, enable: true, balance: Double(1.1212))
        assets.append(asset1)
        
        let asset2 = Asset(symbol: "WETH", name: "Wrapped ETH", icon: UIImage(named: "ETH")!, enable: true, balance: Double(3.1))
        assets.append(asset2)
        
        let asset3 = Asset(symbol: "ZRX", name: "0x", icon: UIImage(named: "ZRX")!, enable: true, balance: Double(5359))
        assets.append(asset3)
        
        let asset4 = Asset(symbol: "REP", name: "Augur", icon: UIImage(named: "REP")!, enable: true, balance: Double(5.33133))
        assets.append(asset4)
        
        assets.append(asset3)
        assets.append(asset3)
        assets.append(asset3)
        assets.append(asset3)
    }
}
