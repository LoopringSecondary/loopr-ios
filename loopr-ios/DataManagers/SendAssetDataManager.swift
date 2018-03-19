//
//  SendAssetDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SendAssetDataManager {
    
    static let shared = SendAssetDataManager()
    
    var amount: Double
    
    // TODO: Use mock data
    private var maxAmount: Double = 96.3236
    
    private init() {
        amount = 0.0
    }

}
