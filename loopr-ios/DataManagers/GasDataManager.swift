//
//  GasDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/5/4.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import Geth

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
    
    private var gasPrice: Double // gwei
    private var gasLimits: [GasLimit]
    private var gasAmount: Double
    
    private init() {
        self.gasPrice = 0
        self.gasAmount = 0
        self.gasLimits = []
        self.getEstimateGasPrice()
        self.loadGasLimitsFromJson()
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
    
    func getGasLimit(by type: String) -> Int64? {
        var gasLimit: Int64? = nil
        for case let gas in gasLimits where gas.type.lowercased() == type.lowercased() {
            gasLimit = gas.gasLimit
            break
        }
        return gasLimit
    }
    
    func getGasAmountInETH(by type: String) -> Double {
        var result: Double = 0
        if let limit = getGasLimit(by: type) {
            result = self.gasPrice * Double(limit)
        } else {
            result = self.gasPrice * 20000
        }
        return result / 1000000000
    }
    
    func getGasAmount(by type: String, in token: String) -> Double {
        let gasInETH = getGasAmountInETH(by: type)
        let tradingPair = "\(token)-WETH"
        let price = MarketDataManager.shared.getBalance(of: tradingPair)
        return gasInETH / price
    }
    
    func getEstimateGasPrice() {
        let semaphore = DispatchSemaphore(value: 0)
        LoopringAPIRequest.getEstimateGasPrice { (gasPrice, error) in
            guard error == nil && gasPrice != nil else {
                return
            }
            self.gasPrice = gasPrice! * 1000000000
            self.gasPrice.round()
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func setGasPrice(to gasPrice: Double) {
        self.gasPrice = gasPrice
    }
    
    func getGasPriceInGwei() -> Double {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: UserDefaultsKeys.gasPrice.rawValue) {
            return defaults.double(forKey: UserDefaultsKeys.gasPrice.rawValue)
        } else {
            return self.gasPrice
        }
    }
    
    func getGasPriceInWei() -> GethBigInt {
        let price = getGasPriceInGwei()
        let amountInWei = GethBigInt.convertGweiToWei(from: price)!
        return amountInWei
    }
}
