//
//  GethBigInt+Extension.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

public extension GethBigInt {

    // Double has a precision of 15 decimal digits,
    // whereas the precision of Float can be as little as 6 decimal digits.
    // For Double type, 1.123456789123456789 will be 1.1234567891234568
    // It's not correct to assume that valueInEther as a Double type won't be overflow.
    public static func generateBigInt(valueInEther: Double, symbol: String) -> GethBigInt? {
        let token = TokenDataManager.shared.getTokenBySymbol(symbol)
        guard token != nil else {
            return nil
        }
        return generateBigInt(valueInEther, token!.decimals)
    }

    public static func generateBigInt(_ valueInEther: Double, _ decimals: Int = 18) -> GethBigInt? {
        let valueInWei = valueInEther * Double.init(truncating: (pow(10, decimals) as NSNumber))
        let str = String(format: "%.0f", valueInWei)
        let gethAmount = GethBigInt.init(0)!
        gethAmount.setString(str, base: 10)
        return gethAmount
    }

    public static func generate(valueInEther: String, symbol: String) -> GethBigInt? {
        let token = TokenDataManager.shared.getTokenBySymbol(symbol)
        guard token != nil else {
            return nil
        }
        return generate(valueInEther, token!.decimals)
    }
    
    public static func generate(_ valueInEther: String, _ decimals: Int = 18) -> GethBigInt? {
        guard valueInEther.isDouble else {
            return nil
        }
        
        let items = valueInEther.components(separatedBy: ".")

        if items.count == 1 {
            let append = String(repeating: "0", count: decimals)
            let valueInWei = items[0] + append
            let gethAmount = GethBigInt.init(0)!
            gethAmount.setString(valueInWei, base: 10)
            return gethAmount
            
        } else if items.count == 2 {
            let fractionalPart = items[1]
            guard fractionalPart.count <= decimals else {
                return nil
            }

            let append = fractionalPart + String(repeating: "0", count: decimals-fractionalPart.count)
            let valueInWei = items[0] + append
            let gethAmount = GethBigInt.init(0)!
            gethAmount.setString(valueInWei, base: 10)
            return gethAmount
        } else {
            return nil
        }
    }
    
    public static func convertGweiToWei(from gweiAmount: Double) -> GethBigInt? {
        let gweiAmountString = String(format: "%.9f", gweiAmount)
        let amountInWei = generate(gweiAmountString, 9)
        return amountInWei
    }

    public var decimalString: String {
        return self.getString(10)
    }
    
    public var hexString: String {
        return "0x" + self.getString(16)
    }
}
