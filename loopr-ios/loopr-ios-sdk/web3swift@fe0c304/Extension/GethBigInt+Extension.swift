//
//  GethBigInt+Extension.swift
//  web3swift
//
//  Created by Sameer Khavanekar on 1/24/18.
//  Copyright © 2018 Radical App LLC. All rights reserved.
//

import Foundation
import Geth

public extension GethBigInt {
    
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
        let gethAmount = GethBigInt.init(0)! // GethNewBigInt(int64_t(valueInWei))
        gethAmount.setString(str, base: 10)
        return gethAmount
    }

    public var decimalString: String {
        return self.getString(10)
    }
    
    public var hexString: String {
        return "0x" + self.getString(16)
    }
}
