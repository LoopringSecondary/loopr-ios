//
//  GasDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/5/4.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

struct GasLimit {
    let type: String
    let gasLimit: Int64
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.gasLimit = json["gasLimit"].int64Value
    }
}

class GasDataManager {
    
    static let shared = GasDataManager()
    
    //TODO: Is gas price in gwei unit?
    private var gasPrice: Double
    private var gasLimits: [GasLimit]
    private var gasAmount: Double
    
    private init() {
        self.gasPrice = 0
        self.gasAmount = 0
        self.gasLimits = []
        self.loadGasLimitsFromJson()
        self.getEstimateGasPrice()
    }

    func getGasLimits() -> [GasLimit] {
        return gasLimits
    }
    
    // TODO: Why we need to load gas_limit from a json file instead of writing as code.
    // load
    func loadGasLimitsFromJson() {
        if let path = Bundle.main.path(forResource: "gas_limit", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let gas = GasLimit(json: subJson)
                gasLimits.append(gas)
            }
        }
    }
    
    func getGasLimitByType(by type: String) -> Int64? {
        var gasLimit: Int64? = nil
        for case let gas in gasLimits where gas.type.lowercased() == type.lowercased() {
            gasLimit = gas.gasLimit
            break
        }
        return gasLimit
    }
    
    func getGasAmount(by type: String) -> Double {
        if let limit = getGasLimitByType(by: type) {
            return self.gasPrice * Double(limit)
        } else {
            return self.gasPrice * 20000
        }
    }
    
    func getEstimateGasPrice() {
        LoopringAPIRequest.getEstimateGasPrice { (gasPrice, error) in
            guard error == nil && gasPrice != nil else {
                return
            }
            self.gasPrice = gasPrice!
        }
    }
    
    func setGasPrice(to gasPrice: Double) {
        self.gasPrice = gasPrice
    }
    
    func getGasPrice() -> Double {
        return self.gasPrice
    }
}
