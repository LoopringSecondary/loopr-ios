//
//  BigInt+Extension.swift
//  loopr-ios
//
//  Created by kenshin on 2018/11/21.
//  Copyright © 2018 Loopring. All rights reserved.
//
import Foundation
import BigInt
import Geth

extension BigInt {
    func toEth() -> GethBigInt {
        let hexString = String.init(self, radix: 16)
        let gethAmount = GethBigInt.init(0)!
        gethAmount.setString(hexString, base: 16)
        return gethAmount
    }
    
    func toHex() -> String {
        return "0x" + String.init(self, radix: 16)
    }
    
    func toDouble(by decimal: Int) -> Double {
        return Double(self) / pow(10.0, Double(decimal))
    }
    
    static func generate(from valueInEth: String, by decimal: Int) -> BigInt? {
        var result: BigInt?
        if let double = Double(valueInEth) {
            result = generate(from: double, by: decimal)
        }
        return result
    }
    
    static func generate(from valueInEth: Double, by decimal: Int) -> BigInt {
        return BigInt(valueInEth * pow(10.0, Double(decimal)))
    }
}
