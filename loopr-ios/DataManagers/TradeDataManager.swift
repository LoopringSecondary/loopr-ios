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
    static let seperator: String = "-"
    
    var state: OrderTradeState
    var orders: [OriginalOrder] = []
    var balanceInfo: [String: Double] = [:]
    var makerSignature: SignatureData?
    var takerSignature: SignatureData?
    
    var isTaker: Bool = false
    var type: TradeType = .buy
    var makerPrivateKey: String?
    var amountTokenS: Double = 0.0
    var amountTokenB: Double = 0.0
    
    let orderCount: Int = 2
    let byteLength: Int = EthType.MAX_BYTE_LENGTH
    
    var tokenS: Token {
        didSet {
            updatePair()
        }
    }
    var tokenB: Token {
        didSet {
            updatePair()
        }
    }
    var tradePair: String = ""

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
        self.updatePair()
    }
    
    func updatePair() {
        self.tradePair = "\(self.tokenS.symbol)/\(self.tokenB.symbol)"
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
    
    func getOrder(by hash: String) -> OriginalOrder? {
        var result: OriginalOrder? = nil
        let semaphore = DispatchSemaphore(value: 0)        
        LoopringAPIRequest.getOrderByHash(orderHash: hash) { order, error in
            guard error == nil && order != nil else {
                return
            }
            result = order!.originalOrder
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }

    func constructTaker(from maker: OriginalOrder) -> OriginalOrder {
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
        
        return OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB, orderType: "p2p_order")
    }
    
    func validate(completion: @escaping (String?, Error?) -> Void) -> Bool {
        var result = false
        if self.orders.count == 2 {
            let maker = orders[0]
            let taker = orders[1]
            if self.makerPrivateKey != nil && maker.hash != ""
                && taker.hash != "" && taker.authPrivateKey != "" {
                result = true
            }
        } else {
            var userInfo: [String: Any] = [:]
            userInfo["message"] = NSLocalizedString("Information of two orders not complete!", comment: "")
            let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
            completion(nil, error)
        }
        return result
    }
    
    func _submitRing(completion: @escaping (String?, Error?) -> Void) {
        guard validate(completion: completion) else { return }
        guard let rawTx = _generate(completion: completion) else { return }
        let makerOrderHash = orders[0].hash
        let takerOrderHash = orders[1].hash
        LoopringAPIRequest.submitRing(makerOrderHash: makerOrderHash, takerOrderHash: takerOrderHash, rawTx: rawTx, completionHandler: completion)
    }
    
    func generateOffset() -> [Any] {
        var result: [Any] = []
        result.append(GethBigInt.init(Int64(byteLength * 9)))
        result.append(GethBigInt.init(Int64(byteLength * 18)))
        result.append(GethBigInt.init(Int64(byteLength * 31)))
        result.append(GethBigInt.init(Int64(byteLength * 34)))
        result.append(GethBigInt.init(Int64(byteLength * 37)))
        result.append(GethBigInt.init(Int64(byteLength * 42)))
        result.append(GethBigInt.init(Int64(byteLength * 45)))
        return result
    }
    
    func generateFee() -> [Any] {
        var result: [Any] = []
        result.append(GethAddress.init(fromHex: orders[0].walletAddress)) // feeReceipt
        result.append(GethBigInt.init(0)) // feeSelection
        return result
    }
    
    func insertOrderCounts() -> [Any] {
        var result: [Any] = []
        result.append(GethBigInt.init(Int64(orderCount)))
        return result
    }
    
    func insertListCounts() -> [Any] {
        var result: [Any] = []
        result.append(GethBigInt.init(Int64(orderCount * 2)))
        return result
    }
    
    func generateAddresses() -> [Any] {
        var result: [Any] = []
        for order in orders {
            let tokenS = TokenDataManager.shared.getAddress(by: order.tokenSell)!
            result.append(GethAddress.init(fromHex: order.address))
            result.append(GethAddress.init(fromHex: tokenS))
            result.append(GethAddress.init(fromHex: order.walletAddress))
            result.append(GethAddress.init(fromHex: order.authAddr))
        }
        return result
    }
    
    func generateValues() -> [Any] {
        var result: [Any] = []
        for order in orders {
            let amountSell = GethBigInt.generate(valueInEther: order.amountSell, symbol: order.tokenSell)!
            result.append(amountSell)
            result.append(GethBigInt.generate(valueInEther: order.amountBuy, symbol: order.tokenBuy)!)
            result.append(GethBigInt.init(order.validSince))
            result.append(GethBigInt.init(order.validUntil))
            result.append(GethBigInt.init(0)) // 对手单, 不需要lrcfee
            result.append(amountSell)
        }
        return result
    }
    
    func generateMargin() -> [Any] {
        var result: [Any] = []
        for _ in orders {
            result.append(GethBigInt.init(0)) // 对手单, 不需要margin split
        }
        return result
    }
    
    func generateFlag() -> [Any] {
        var result: [Any] = []
        for order in orders {
            let flag = order.buyNoMoreThanAmountB ? 1 : 0
            result.append(GethBigInt.init(Int64(flag)))
        }
        return result
    }
    
    func generateVList() -> [Any] {
        var result: [Any] = []
        for order in orders {
            result.append(GethBigInt.init(Int64(order.v)))
        }
        if let maker = makerSignature, let taker = takerSignature {
            result.append(GethBigInt.init(Int64(maker.v)!))
            result.append(GethBigInt.init(Int64(taker.v)!))
        }
        return result
    }
    
    func generateRList() -> [Any] {
        var result: [Any] = []
        for order in orders {
            result.append(order.r.hexBytes)
        }
        if let maker = makerSignature, let taker = takerSignature {
            result.append(maker.r.hexBytes) // TODO: check here
            result.append(taker.r.hexBytes)
        }
        return result
    }
    
    func generateSList() -> [Any] {
        var result: [Any] = []
        for order in orders {
            result.append(order.r.hexBytes)
        }
        if let maker = makerSignature, let taker = takerSignature {
            result.append(maker.s.hexBytes) // TODO: check here
            result.append(taker.s.hexBytes)
        }
        return result
    }
    
    func encode() -> Data {
        var array: [Any] = generateOffset()
        array += generateFee()
        array += insertOrderCounts()
        array += generateAddresses()
        array += insertOrderCounts()
        array += generateValues()
        array += insertOrderCounts()
        array += generateMargin()
        array += insertOrderCounts()
        array += generateFlag()
        array += insertListCounts()
        array += generateVList()
        array += insertListCounts()
        array += generateRList()
        array += insertListCounts()
        array += generateSList()
        let function = Data("0xe78aadb2".hexBytes)
        return function + EthFunctionEncoder.default.encodeParameters(array, methodData: Data())
    }
    
    func generateHash() -> Data {
        var result: Data = Data()
        let orderAHash = orders[0].hash.hexBytes
        let orderBHash = orders[1].hash.hexBytes
        for t in orderAHash.enumerated() {
            result.append(t.element ^ orderBHash[t.offset])
        }
        result.append(contentsOf: orders[0].walletAddress.hexBytes)
        result.append(contentsOf: [0, 0]) // feeSelection = 0 UInt16
        return result
    }
    
    func _generate(completion: @escaping (String?, Error?) -> Void) -> String? {
        self.signRinghash()
        let data = encode()
        var error: NSError? = nil
        let protocolAddress = GethNewAddressFromHex(RelayAPIConfiguration.protocolAddress, &error)!
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "submitRing")!
        return SendCurrentAppWalletDataManager.shared._sign(data: data, address: protocolAddress, amount: GethBigInt.init(0), gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func signHash(privateKey: String, hash: Data) -> SignatureData? {
        let password = "123456"
        
        // Generate keystore data. Note that: this is slow in the debug mode, however it's fast in the release mode.
        let data = Data(hexString: privateKey)!
        let key = try! KeystoreKey(password: password, key: data)
        let keystoreData = try! JSONEncoder().encode(key)
        let json = try! JSON(data: keystoreData)
        let keystoreStringValue = json.description
        print(keystoreStringValue)
        
        // Create key directory
        let fileManager = FileManager.default
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("signHash")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("signHash")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)
        
        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!

        // Need to call this one just before sign
        guard let _: GethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: password) else {
            print("Failed to init EthAccountCoordinator")
            return nil
        }
        let signature = web3swift.sign(message: hash)!
        return signature
    }
    
    func signRinghash() {
        let hash = generateHash()
        makerSignature = signHash(privateKey: self.makerPrivateKey!, hash: hash)
        takerSignature = signHash(privateKey: orders[1].authPrivateKey, hash: hash)
    }

    func verify(order: OriginalOrder) -> [String: Double] {
        balanceInfo = [:]
        checkGasEnough(of: order)
        return balanceInfo
    }
    
    func checkGasEnough(of order: OriginalOrder) {
        var result: Double = 0
        if let ethBalance = CurrentAppWalletDataManager.shared.getBalance(of: "ETH"), let tokenGas = calculateGas(for: order.tokenSell, to: order.amountSell) {
            if isTaker {
                let gasAmount = GasDataManager.shared.getGasAmountInETH(by: "submitRing")
                result = ethBalance - tokenGas - gasAmount
            } else {
                result = ethBalance - tokenGas
            }
        }
        if result < 0 {
            balanceInfo["MINUS_ETH"] = -result
        }
    }
    
    func calculateGas(for token: String, to amount: Double) -> Double? {
        var result: Double? = nil
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: token) {
            let tokenFrozen = PlaceOrderDataManager.shared.getAllowance(of: token)
            if asset.allowance >= amount + tokenFrozen {
                return 0
            }
            let gasAmount = GasDataManager.shared.getGasAmountInETH(by: "approve")
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
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double? {
        let pair = tokenS + "/LRC"
        let ratio = SettingDataManager.shared.getLrcFeeRatio()
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            return market.balance * amountS * ratio
        } else if let price = PriceDataManager.shared.getPrice(of: tokenS),
            let lrcPrice = PriceDataManager.shared.getPrice(of: "LRC") {
            return price * amountS * ratio / lrcPrice
        }
        return 0.0
    }
    
    func startGetOrderStatus() {
        guard let wallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet() else {
            return
        }
        LoopringSocketIORequest.getOrderStatus(owner: wallet.address)
    }
    
    func stopGetOrderStatus() {
        LoopringSocketIORequest.endOrderStatus()
    }
    
    /*
     1. 需要备份maker订单，response中加以判断
     2. 若json中含有maker，需要在接收orderResponseReceived地方判断
     3. 若还在展示二维码，跳转至订单详情；若已经离开，显示banner
     4. 停止接收sockeio的推送
     */
    
    func onOrderResponse(json: JSON) {
        let orders = json["orders"].arrayValue
        NotificationCenter.default.post(name: .orderResponseReceived, object: nil)
    }
}
