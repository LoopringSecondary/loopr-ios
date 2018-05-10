//
//  PlaceOrderDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class PlaceOrderDataManager {
    
    static let shared = PlaceOrderDataManager()
    
    private var errorInfo: [String: Any] = [:]
    private var balanceInfo: [String: Double] = [:]
    
    private let gasManager = GasDataManager.shared
    private let tokenManager = TokenDataManager.shared
    private let walletManager = CurrentAppWalletDataManager.shared
    private let sendManager = SendCurrentAppWalletDataManager.shared
    
    // Similar naming in Trade.swift
    var tokenA: Token!
    var tokenB: Token!
    var market: Market!

    func new(tokenA: String, tokenB: String, market: Market) {
        self.tokenA = TokenDataManager.shared.getTokenBySymbol(tokenA)!
        self.tokenB = TokenDataManager.shared.getTokenBySymbol(tokenB)!
        self.market = market
    }

    func complete() -> Bool {
        return true
    }
    
    func getFrozenLRCFeeFromServer() -> Double {
        var result: Double = 0
        let semaphore = DispatchSemaphore(value: 0)
        if let address = walletManager.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getFrozenLRCFee(owner: address, completionHandler: { (data, error) in
                guard error == nil, let lrc = data else {
                    return
                }
                result = lrc
                semaphore.signal()
            })
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    func getEstimatedAllocatedAllowanceFromServer(token: String) -> Double {
        var result: Double = 0
        let semaphore = DispatchSemaphore(value: 0)
        if let address = walletManager.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getEstimatedAllocatedAllowance(owner: address, token: token, completionHandler: { (data, error) in
                guard error == nil, let allowance = data else {
                    return
                }
                result = allowance
                semaphore.signal()
            })
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }

    func checkLRCEnough(of order: OriginalOrder) {
        var result: Double = 0
        let lrcFrozen = getFrozenLRCFeeFromServer()
        let lrcBlance = walletManager.getBalance(of: "LRC")!
        result = lrcBlance - order.lrcFee - lrcFrozen
        if result < 0 {
            balanceInfo["MINUS_LRC"] = -result
        }
    }
    
    // TODO: what usecase needs to include LRC?
    // TODO: it's better to explicitly define some values.
    func checkGasEnough(of order: OriginalOrder, includingLRC: Bool = true) {
        var result: Double = 0
        if let ethBalance = walletManager.getBalance(of: "ETH"),
            let tokenGas = calculateGas(for: order.tokenSell, to: order.amountSell, lrcFee: order.lrcFee) {
            if includingLRC {
                if let lrcGas = calculateGas(for: "LRC", to: order.amountSell, lrcFee: order.lrcFee) {
                    result = ethBalance - lrcGas - tokenGas
                }
            } else {
                result = ethBalance - tokenGas
            }
        }
        if result < 0 {
            balanceInfo["MINUS_ETH"] = -result
        }
    }
    
    func checkLRCGasEnough(of order: OriginalOrder) {
        var result: Double = 0
        if let ethBalance = walletManager.getBalance(of: "ETH"),
            let lrcGas = calculateGasForLRC(of: order) {
            result = ethBalance - lrcGas
        }
        if result < 0 {
            balanceInfo["MINUS_ETH"] = -result
        }
    }
    
    func calculateGas(for token: String, to amount: Double, lrcFee: Double) -> Double? {
        var result: Double? = nil
        if let asset = walletManager.getAsset(symbol: token) {
            if token.uppercased() == "LRC" {
                // 这里很慢！！！！！！！！！！！
                let lrcFrozen = getFrozenLRCFeeFromServer()
                let sellingFrozen = getEstimatedAllocatedAllowanceFromServer(token: "LRC")
                if asset.allowance >= lrcFee + lrcFrozen + sellingFrozen {
                    return 0
                }
            } else {
                let tokenFrozen = getEstimatedAllocatedAllowanceFromServer(token: token)
                if asset.allowance >= amount + tokenFrozen {
                    return 0
                }
            }
            let gasAmount = gasManager.getGasAmountInETH(by: "approve")
            if asset.allowance == 0 {
                result = gasAmount
                balanceInfo["GAS_\(asset.symbol)"] = 1
            } else {
                result = gasAmount * 2
                balanceInfo["GAS_\(asset.symbol)"] = 2
            }
        }
        return result
    }
    
    func calculateGasForLRC(of order: OriginalOrder) -> Double? {
        var result: Double? = nil
        if let asset = walletManager.getAsset(symbol: "LRC") {
            let lrcAllowance = asset.allowance
            let lrcFee = order.lrcFee
            let amountSell = order.amountSell
            let lrcFrozen = getFrozenLRCFeeFromServer()
            let sellingFrozen = getEstimatedAllocatedAllowanceFromServer(token: "LRC")
            if lrcFee + lrcFrozen + sellingFrozen + amountSell > lrcAllowance {
                let gasAmount = gasManager.getGasAmountInETH(by: "approve")
                if lrcAllowance == 0 {
                    result = gasAmount
                    balanceInfo["GAS_LRC"] = 1
                } else {
                    result = gasAmount * 2
                    balanceInfo["GAS_LRC"] = 2
                }
            } else {
                return 0
            }
        }
        return result
    }
    
    /*
     1. LRC FEE 比较的是当前订单lrc fee + getFrozenLrcfee() >< 账户lrc 余额 不够失败
     2. 如果够了，看lrc授权够不够，够则成功，如果不够需要授权是否等于=0，如果不是，先授权lrc = 0， 再授权lrc = max，是则直接授权lrc = max。看两笔授权支付的eth gas够不够，如果eth够则两次授权，不够失败
     3. 比较当前订单amounts + loopring_getEstimatedAllocatedAllowance() >< 账户授权tokens，够则成功，不够则看两笔授权支付的eth gas够不够，如果eth够则两次授权，不够失败
     如果是sell lrc，需要lrc fee + getFrozenLrcfee() + amounts(lrc) + loopring_getEstimatedAllocatedAllowance() >< 账户授权lrc
     4. buy lrc不看前两点，只要3满足即可
     */
    func verify(order: OriginalOrder) -> [String: Double] {
        balanceInfo = [:]
        if order.side == "buy" {
            if order.tokenBuy.uppercased() == "LRC" {
                checkGasEnough(of: order, includingLRC: false)
            } else {
                checkLRCEnough(of: order)
                checkGasEnough(of: order)
            }
        } else {
            if order.tokenSell.uppercased() == "LRC" {
                checkLRCEnough(of: order)
                checkLRCGasEnough(of: order)
            } else {
                checkLRCEnough(of: order)
                checkGasEnough(of: order)
            }
        }
        return balanceInfo
    }
    
    func getOrderHash(order: OriginalOrder) -> Data {
        var result: Data = Data()
        result.append(contentsOf: order.delegate.hexBytes)
        result.append(contentsOf: order.address.hexBytes)
        let tokens = TokenDataManager.shared.getAddress(by: order.tokenSell)!
        result.append(contentsOf: tokens.hexBytes)
        let tokenb = TokenDataManager.shared.getAddress(by: order.tokenBuy)!
        result.append(contentsOf: tokenb.hexBytes)
        result.append(contentsOf: order.walletAddress.hexBytes)
        result.append(contentsOf: order.authAddr.hexBytes)
        result.append(contentsOf: _encode(order.amountSell, order.tokenSell))
        result.append(contentsOf: _encode(order.amountBuy, order.tokenBuy))
        result.append(contentsOf: _encode(order.validSince))
        result.append(contentsOf: _encode(order.validUntil))
        result.append(contentsOf: _encode(order.lrcFee, "LRC"))
        let flag: [UInt8] = order.buyNoMoreThanAmountB ? [1] : [0]
        result.append(contentsOf: flag)
        result.append(contentsOf: [order.marginSplitPercentage])
        return result
    }
    
    func _encode(_ amount: Double, _ token: String) -> [UInt8] {
        let bigInt = GethBigInt.generateBigInt(valueInEther: amount, symbol: token)!
        return try! EthTypeEncoder.default.encode(bigInt).bytes
    }
    
    func _encode(_ value: Int64) -> [UInt8] {
        let bigInt = GethBigInt.init(value)!
        return try! EthTypeEncoder.default.encode(bigInt).bytes
    }
    
    func _encodeString(_ amount: Double, _ token: String) -> String {
        let bigInt = GethBigInt.generateBigInt(valueInEther: amount, symbol: token)!
        return bigInt.hexString
    }
    
    func _submit(order: OriginalOrder, completion: @escaping (String?, Error?) -> Void) {
        let orderData = getOrderHash(order: order)

        SendCurrentAppWalletDataManager.shared._keystore()
        let signature = web3swift.sign(message: orderData)!
        let tokens = tokenManager.getAddress(by: order.tokenSell)!
        let tokenb = tokenManager.getAddress(by: order.tokenBuy)!
        let amountB = _encodeString(order.amountBuy, order.tokenBuy)
        let amountS = _encodeString(order.amountSell, order.tokenSell)
        let lrcFee = _encodeString(order.lrcFee, "LRC")
        let validSince = "0x" + String(format: "%2x", order.validSince)
        let validUntil = "0x" + String(format: "%2x", order.validUntil)
  
        LoopringAPIRequest.submitOrder(owner: order.address, walletAddress: order.walletAddress, tokenS: tokens, tokenB: tokenb, amountS: amountS, amountB: amountB, lrcFee: lrcFee, validSince: validSince, validUntil: validUntil, marginSplitPercentage: order.marginSplitPercentage, buyNoMoreThanAmountB: order.buyNoMoreThanAmountB, authAddr: order.authAddr, authPrivateKey: order.authPrivateKey, v: UInt(signature.v)!, r: signature.r, s: signature.s, completionHandler: completion)
    }
}
