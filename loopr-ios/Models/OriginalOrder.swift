//
//  OriginalOrder.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OriginalOrder {

    // protocol is a keyword in Swift
    let delegate: String
    let address: String
    let market: String
    let tokenBuy: String
    let tokenSell: String
    let amountBuy: Double
    let amountSell: Double
    let validSince: Int64
    let validUntil: Int64
    let lrcFee: Double
    let buyNoMoreThanAmountB: Bool
    let side: String
    let hash: String
    let walletAddress: String
    let authPrivateKey: String
    let authAddr: String
    let marginSplitPercentage: UInt8
    let v: UInt8
    let r: String
    let s: String
    
    init(delegate: String, address: String, side: String, tokenS: String, tokenB: String, validSince: Int64, validUntil: Int64, amountBuy: Double, amountSell: Double, lrcFee: Double, buyNoMoreThanAmountB: Bool, market: String = "", hash: String = "", v: UInt8 = 0, r: String = "", s: String = "") {
        self.delegate = delegate
        self.address = address
        self.market = market
        self.validSince = validSince
        self.validUntil = validUntil
        self.tokenSell = tokenS
        self.tokenBuy = tokenB
        self.amountSell = amountSell
        self.amountBuy = amountBuy
        self.lrcFee = lrcFee
        self.side = side
        self.hash = hash
        self.buyNoMoreThanAmountB = buyNoMoreThanAmountB
        let (privateKey, walletAddress) = Wallet.generateRandomWallet()
        self.authAddr = walletAddress
        self.authPrivateKey = privateKey
        self.walletAddress = RelayAPIConfiguration.orderWalletAddress
        self.marginSplitPercentage = UInt8(SettingDataManager.shared.getMarginSplit() * 100)
        self.v = v
        self.r = r
        self.s = s
    }

    init(json: JSON) {
        self.delegate = json["protocol"].stringValue
        self.address = json["address"].stringValue
        self.market = json["market"].stringValue
        self.tokenSell = json["tokenS"].stringValue
        self.tokenBuy = json["tokenB"].stringValue
        self.buyNoMoreThanAmountB = json["buyNoMoreThanAmountB"].boolValue
        self.side = json["side"].stringValue
        self.hash = json["hash"].stringValue
        self.v = UInt8(json["v"].stringValue.dropFirst(2), radix: 16)!
        self.r = json["r"].stringValue
        self.s = json["s"].stringValue
        self.walletAddress = json["walletAddress"].stringValue
        self.authAddr = json["authAddr"].stringValue
        self.authPrivateKey = json["authPrivateKey"].stringValue
        self.marginSplitPercentage = UInt8(json["marginSplitPercentage"].stringValue.dropFirst(2), radix: 16)!
        self.validSince = Int64(json["validSince"].stringValue.dropFirst(2), radix: 16)!
        self.validUntil = Int64(json["validUntil"].stringValue.dropFirst(2), radix: 16)!
        let amountS = json["amountS"].stringValue
        self.amountSell = Asset.getAmount(of: self.tokenSell, fromGweiAmount: amountS) ?? 0.0
        let amountB = json["amountB"].stringValue
        self.amountBuy = Asset.getAmount(of: self.tokenBuy, fromGweiAmount: amountB) ?? 0.0
        let fee = json["lrcFee"].stringValue
        self.lrcFee = Asset.getAmount(of: "LRC", fromGweiAmount: fee)!
    }
}
