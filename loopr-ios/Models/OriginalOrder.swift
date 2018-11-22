//
//  OriginalOrder.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import BigInt

class OriginalOrder {

    // protocol is a keyword in Swift
    var delegate: String = ""
    var address: String = ""
    var market: String = ""
    var tokenBuy: String = ""
    var tokenSell: String = ""
    var amountB: BigInt = 0 // use for sign order & submit
    var amountBuy: Double = 0.0 // use for display & check
    var amountS: BigInt = 0 // use for sign order & submit
    var amountSell: Double = 0.0 // use for display & check
    var validSince: Int64 = 0
    var validUntil: Int64 = 0
    var lrcFee: Double = 0
    var buyNoMoreThanAmountB: Bool = false
    var side: String = ""
    var hash: String = ""
    var walletAddress: String = ""
    var authPrivateKey: String = ""
    var authAddr: String = ""
    var marginSplitPercentage: UInt8 = 0
    var orderType: OrderType = .marketOrder
    var p2pType: P2PType = .maker
    var v: UInt = 0
    var r: String = ""
    var s: String = ""
    
    init(delegate: String, address: String, side: String, tokenS: String, tokenB: String, validSince: Int64, validUntil: Int64, amountBuy: Double, amountSell: Double, lrcFee: Double, buyNoMoreThanAmountB: Bool, amountS: BigInt? = nil, amountB: BigInt? = nil, orderType: OrderType = .marketOrder, p2pType: P2PType = .maker, market: String = "") {
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
        self.orderType = orderType
        self.p2pType = p2pType
        self.buyNoMoreThanAmountB = buyNoMoreThanAmountB
        let (privateKey, walletAddress) = Wallet.generateRandomWallet()
        self.authAddr = walletAddress
        self.authPrivateKey = privateKey
        self.walletAddress = PartnerDataManager.shared.getWalletAddress()
        self.marginSplitPercentage = UInt8(SettingDataManager.shared.getMarginSplit() * 100)
        self.amountS = amountS ?? BigInt(0)
        self.amountB = amountB ?? BigInt(0)
    }

    init(json: JSON) {
        self.delegate = json["delegateAddress"].stringValue
        self.market = json["market"].stringValue
        self.address = getAddress(json: json)
        self.tokenBuy = OriginalOrder.getToken(json["tokenB"].stringValue)
        self.tokenSell = OriginalOrder.getToken(json["tokenS"].stringValue)
        let amountS = json["amountS"].stringValue
        self.amountSell = Asset.getAmount(of: self.tokenSell, fromWeiAmount: amountS) ?? 0.0
        let amountB = json["amountB"].stringValue
        self.amountBuy = Asset.getAmount(of: self.tokenBuy, fromWeiAmount: amountB) ?? 0.0
        self.amountS = BigInt(amountS.drop0x(), radix: 16) ?? 0
        self.amountB = BigInt(amountB.drop0x(), radix: 16) ?? 0
        self.buyNoMoreThanAmountB = json["buyNoMoreThanAmountB"].boolValue
        self.hash = json["hash"].stringValue
        let orderType = OrderType(rawValue: json["orderType"].stringValue) ?? OrderType.unknown
        let p2pType = P2PType(rawValue: json["p2pSide"].stringValue) ?? P2PType.unknown
        if orderType == .p2pOrder {
            self.side = p2pType == .maker ? "sell" : "buy"
        } else {
            self.side = json["side"].stringValue
        }
        self.orderType = orderType
        self.p2pType = p2pType
        self.walletAddress = json["walletAddress"].stringValue
        self.authAddr = json["authAddr"].stringValue
        self.authPrivateKey = json["authPrivateKey"].stringValue
        self.validSince = Int64(getInt(json["validSince"].string))
        self.validUntil = Int64(getInt(json["validUntil"].string))
        self.marginSplitPercentage = getMargin(json: json)
        let fee = json["lrcFee"].stringValue
        self.lrcFee = Asset.getAmount(of: "LRC", fromWeiAmount: fee)!
        self.r = json["r"].stringValue
        self.s = json["s"].stringValue
        self.v = UInt(getInt(json["v"].string))
    }
    
    func getMargin(json: JSON) -> UInt8 {
        var result: UInt8 = 0
        if let string = json["marginSplitPercentage"].string {
            result = UInt8(getInt(string))
        } else if let integer = json["marginSplitPercentage"].uInt8 {
            result = integer
        }
        return result
    }
    
    func getAddress(json: JSON) -> String {
        var result: String = ""
        if let address = json["address"].string {
            result = address
        } else if let owner = json["owner"].string {
            result = owner
        }
        return result
    }
    
    func getInt(_ value: String?) -> Int {
        var result: Int = 0
        if let value = value {
            if value.isHex(), let integer = Int(value.dropFirst(2), radix: 16) {
                result = integer
            }
        }
        return result
    }
    
    class func getToken(_ address: String) -> String {
        var result: String = address
        if address.isHex() {
            if let token = TokenDataManager.shared.getTokenByAddress(address) {
                result = token.symbol
            }
        }
        return result
    }
}
