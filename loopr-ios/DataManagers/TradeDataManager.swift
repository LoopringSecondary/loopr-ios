//
//  TradeDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class TradeDataManager {
    
    static let shared = TradeDataManager()
    
    var state: OrderTradeState
    
    var type: TradeType = .buy

    var tokenS: Token
    var tokenB: Token
    
    var amountTokenS: Double = 0.0
    var amountTokenB: Double = 0.0

    private init() {
        state = .empty
        // Get TokenS and TokenB from UserDefaults
        let defaults = UserDefaults.standard
        var tokenS: Token? = nil
        if let symbol = defaults.string(forKey: UserDefaultsKeys.tradeTokenS.rawValue) {
            tokenS = Token(symbol: symbol)
        }
        self.tokenS = tokenS ?? Token(symbol: "LRC")!
        var tokenB: Token? = nil
        if let symbol = defaults.string(forKey: UserDefaultsKeys.tradeTokenB.rawValue) {
            tokenB = Token(symbol: symbol)
        }
        self.tokenB = tokenB ?? Token(symbol: "WETH")!
    }

    func clear() {
        state = .empty
    }

    func changeTokenS(_ token: Token) {
        tokenS = token
        let defaults = UserDefaults.standard
        defaults.set(token.symbol, forKey: UserDefaultsKeys.tradeTokenS.rawValue)
    }

    func changeTokenB(_ token: Token) {
        tokenB = token
        let defaults = UserDefaults.standard
        defaults.set(token.symbol, forKey: UserDefaultsKeys.tradeTokenB.rawValue)
    }

    func constructTaker(from maker: OriginalOrder) -> OriginalOrder? {
        var buyNoMoreThanAmountB: Bool
        var side, tokenSell, tokenBuy: String
        var amountBuy, amountSell, lrcFee: Double
        if maker.side == "buy" {
            side = "sell"
            buyNoMoreThanAmountB = false
        } else {
            side = "buy"
            buyNoMoreThanAmountB = true
        }
        tokenBuy = maker.tokenSell
        tokenSell = maker.tokenBuy
        amountBuy = maker.amountSell
        amountSell = maker.amountBuy
        
        lrcFee = getLrcFee(amountSell, tokenSell)!
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        let since = Int64(Date().timeIntervalSince1970)
        // P2P 订单 默认 1hour 过期，或增加ui调整
        let until = Int64(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!.timeIntervalSince1970)
        
        return OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB)
    }
    
    func _submitRing(order: OriginalOrder, makerOrderHash: String, rawTx: String, completion: @escaping (String?, Error?) -> Void) {
        if let order = constructTaker(from: order) {
            SendCurrentAppWalletDataManager.shared._keystore()
            let signature = web3swift.sign(message: Data())! // TODO: get from go framework
            let tokenS = TokenDataManager.shared.getAddress(by: order.tokenSell)!
            let tokenB = TokenDataManager.shared.getAddress(by: order.tokenBuy)!
            let amountS = GethBigInt.generateBigInt(valueInEther: order.amountSell, symbol: order.tokenSell)!.hexString
            let amountB = GethBigInt.generateBigInt(valueInEther: order.amountBuy, symbol: order.tokenBuy)!.hexString
            let lrcFee = GethBigInt.generateBigInt(valueInEther: order.lrcFee, symbol: "LRC")!.hexString
            let validSince = "0x" + String(format: "%2x", order.validSince)
            let validUntil = "0x" + String(format: "%2x", order.validUntil)
            LoopringAPIRequest.submitRing(owner: order.address, walletAddress: order.walletAddress, tokenS: tokenS, tokenB: tokenB, amountS: amountS, amountB: amountB, lrcFee: lrcFee, validSince: validSince, validUntil: validUntil, marginSplitPercentage: order.marginSplitPercentage, buyNoMoreThanAmountB: order.buyNoMoreThanAmountB, authAddr: order.authAddr, v: UInt(signature.v)!, r: signature.r, s: signature.s, makerOrderHash: makerOrderHash, rawTx: rawTx, completionHandler: completion)
        }
    }
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double? {
        let pair = tokenS + "/LRC"
        let ratio = SettingDataManager.shared.getLrcFeeRatio()
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            return market.balance * amountS * ratio
        } else if let price = PriceDataManager.shared.getPriceBySymbol(of: tokenS),
            let lrcPrice = PriceDataManager.shared.getPriceBySymbol(of: "LRC") {
            return price * amountS * ratio / lrcPrice
        }
        return nil
    }
}
