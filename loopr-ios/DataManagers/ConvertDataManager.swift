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
    
    // TODO: Use mock data
    private var maxAmount: Double = 96.3236
    
    private init() {
        amount = 0.0
    }
    
    func clear() {
        amount = 0.0
    }

    func setup() {
        print("setup ConvertDataManager")
        
        // Get the available amount

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
