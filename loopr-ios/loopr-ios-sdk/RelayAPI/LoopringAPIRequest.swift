//
//  JSON_RPC.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// https://github.com/Loopring/relay/blob/wallet_v2/LOOPRING_RELAY_API_SPEC_V2.md#loopring_getorders
class LoopringAPIRequest {

    static func invoke<T: Initable>(method: String, withBody body: inout JSON, _ completionHandler: @escaping (_ response: T?, _ error: Error?) -> Void) {
        body["method"] = JSON(method)
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var json = JSON(data)
            if json["result"] != JSON.null {
                completionHandler(T.init(json["result"]), nil)
            } else if json["error"] != JSON.null {
                var userInfo: [String: Any] = [:]
                let code = json["error"]["code"].intValue
                userInfo["message"] = json["error"]["message"].stringValue
                let error = NSError(domain: method, code: code, userInfo: userInfo)
                completionHandler(nil, error)
            }
        }
    }
    
    // READY
    public static func getBalance(owner: String, completionHandler: @escaping (_ assets: [Asset], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress, "owner": owner]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler([], error)
                return
            }
            let json = JSON(data)
            var assets: [Asset] = []
            let offerData = json["result"]["tokens"]
            for subJson in offerData.arrayValue {
                let asset = Asset(json: subJson)
                assets.append(asset)
            }
            completionHandler(assets, error)
        }
    }

    // TODO: how to handle unknown status?
    static func getOrders(owner: String? = nil, orderHash: String? = nil, status: String? = nil, market: String? = nil, side: String? = nil, orderType: String? = "market_order", pageIndex: UInt = 1, pageSize: UInt = 50, completionHandler: @escaping (_ orders: [Order]?, _ error: Error?) -> Void) {
        
        var body: JSON = JSON()
        body["method"] = "loopring_getOrders"
        body["params"] = [["owner": owner, "orderHash": orderHash, "delegateAddress": RelayAPIConfiguration.delegateAddress, "status": status, "market": market, "side": side, "orderType": orderType, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler([], error)
                return
            }
            var orders: [Order] = []
            let json = JSON(data)
            let offerData = json["result"]["data"]
            
            for subJson in offerData.arrayValue {
                let originalOrderJson = subJson["originalOrder"]
                let originalOrder = OriginalOrder(json: originalOrderJson)
                let orderStatus = OrderStatus(rawValue: subJson["status"].stringValue) ?? OrderStatus.unknown
                let dealtAmountB = subJson["dealtAmountB"].stringValue
                let dealtAmountS = subJson["dealtAmountS"].stringValue
                let order = Order(originalOrder: originalOrder, orderStatus: orderStatus, dealtAmountB: dealtAmountB, dealtAmountS: dealtAmountS)
                orders.append(order)
            }
            completionHandler(orders, nil)
        }
    }
    
    static func getOrderByHash(orderHash: String, completionHandler: @escaping (_ orders: Order?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getOrderByHash"
        body["params"] = [["orderHash": orderHash]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            let originalOrderJson = offerData["originalOrder"]
            let originalOrder = OriginalOrder(json: originalOrderJson)
            let orderStatus = OrderStatus(rawValue: offerData["status"].stringValue) ?? OrderStatus.unknown
            let dealtAmountB = offerData["dealtAmountB"].stringValue
            let dealtAmountS = offerData["dealtAmountS"].stringValue
            let order = Order(originalOrder: originalOrder, orderStatus: orderStatus, dealtAmountB: dealtAmountB, dealtAmountS: dealtAmountS)
            completionHandler(order, nil)
        }
    }

    // READY
    static func getDepth(market: String, length: UInt, completionHandler: @escaping (_ depth: Depth?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getDepth"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress, "market": market, "length": length]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]["depth"]
            let buyContent = offerData["buy"].arrayObject as! [[String]]
            let sellContent = offerData["sell"].arrayObject as! [[String]]
            let depth = Depth(buyOrders: buyContent, sellOrders: sellContent)
            completionHandler(depth, nil)
        }
    }

    // READY
    static func getTicker(completionHandler: @escaping (_ markets: [Market], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTicker"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var markets: [Market] = []
            let json = JSON(data)
            let offerData = json["result"]
            
            for subJson in offerData.arrayValue {
                if let market = Market(json: subJson) {
                    markets.append(market)
                }
            }
            completionHandler(markets, nil)
        }
    }
    
    static func getTickers(market: String, completionHandler: @escaping (_ markets: [Market], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTickers"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress, "market": market]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var markets: [Market] = []
            let json = JSON(data)
            let offerData = json["result"]
            print(offerData)

            for (key, value) in json["result"] {
                print("key \(key) value2 \(value)")
                if let market = Market(json: value) {
                    market.exchange = key
                    markets.append(market)
                }
            }
            markets.sort(by: { (a, b) -> Bool in
                return a.volumeInPast24 > b.volumeInPast24
            })
            completionHandler(markets, nil)
        }
    }
    
    // READY
    static func getFills(market: String, owner: String?, orderHash: String?, ringHash: String?, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ trades: [Trade]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getFills"
        body["params"] = [["market": market, "delegateAddress": RelayAPIConfiguration.delegateAddress, "owner": owner, "orderHash": orderHash, "ringHash": ringHash]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var trades: [Trade] = []
            let json = JSON(data)
            let offerData = json["result"]["data"]
            for subJson in offerData.arrayValue {
                let trade = Trade(json: subJson)
                trades.append(trade)
            }
            completionHandler(trades, nil)
        }
    }
    
    // READY
    static func getTrend(market: String, interval: String, completionHandler: @escaping (_ trends: [Trend]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTrend"
        body["params"] = [["market": market, "interval": interval, "delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var trends: [Trend] = []
            let json = JSON(data)
            let offerData = json["result"]
            for subJson in offerData.arrayValue {
                print(subJson)
                let trend = Trend(json: subJson)
                trends.append(trend)
            }
            completionHandler(trends, nil)
        }
    }

    // READY
    static func getRingMined(ringHash: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ minedRings: [MinedRing]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getRingMined"
        body["params"] = [["ringHash": ringHash, "delegateAddress": RelayAPIConfiguration.delegateAddress, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]["data"]
            var minedRings: [MinedRing] = []
            for subJson in offerData.arrayValue {
                let minedRing = MinedRing(json: subJson)
                minedRings.append(minedRing)
            }
            completionHandler(minedRings, nil)
        }
    }
    
    // READY
    static func getCutoff(address: String, blockNumber: String = "latest", completionHandler: @escaping (_ date: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getCutoff"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress, "address": address, "blockNumber": blockNumber]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            let date = DateUtil.convertToDate(offerData.uIntValue, format: "MM-dd YYYY")
            completionHandler(date, nil)
        }
    }
    
    // READY
    static func getPriceQuote(currency: String, completionHandler: @escaping (_ price: PriceQuote?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPriceQuote"
        body["params"] = [["currency": currency, "delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            let price = PriceQuote(json: offerData)
            completionHandler(price, nil)
        }
    }
    
    // READY
    static func getEstimatedAllocatedAllowance(owner: String, token: String, completionHandler: @escaping (_ result: Double?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getEstimatedAllocatedAllowance"
        body["params"] = [["owner": owner, "token": token, "delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)

        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let result = json["result"].stringValue
            if let amount = Asset.getAmount(of: token, fromWeiAmount: result) {
                completionHandler(amount, nil)
            }
        }
    }
    
    static func getSupportedTokens(completionHandler: @escaping (_ tokens: [Token]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedTokens"
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var tokens: [Token] = []
            let json = JSON(data)
            let offerData = json["result"]
            for subJson in offerData.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
            completionHandler(tokens, nil)
        }
    }
    
    // READY
    static func getSupportedMarket(completionHandler: @escaping (_ pairs: [TradingPair]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedMarket"
        body["params"] = [["delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var pairs: [TradingPair] = []
            let json = JSON(data)
            let resultJson = json["result"]
            for pair in resultJson.arrayValue {
                let tokens = pair.stringValue.components(separatedBy: "-")
                let pair = TradingPair(tokens[0], tokens[1])
                pairs.append(pair)
            }
            completionHandler(pairs, nil)
        }
    }
    
    // READY
    static func getTransactions(owner: String, symbol: String, txHash: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 10, completionHandler: @escaping (_ transactions: [Transaction]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTransactions"
        body["params"] = [["owner": owner, "symbol": symbol, "txHash": txHash, "pageIndex": pageIndex, "pageSize": pageSize, "delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            
            let errorMessage = json["error"]
            print("errorMessage: \(errorMessage)")

            let offerData = json["result"]["data"]
            // print("loopring_getTransactions: \(offerData)")
            
            var transactions: [Transaction] = []
            for subJson in offerData.arrayValue {
                if let transaction = Transaction(json: subJson) {
                    transactions.append(transaction)
                }
            }
            completionHandler(transactions, nil)
        }
    }
    
    // READY -- must be invoked from unlock method
    static func unlockWallet(owner: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_unlockWallet"
        body["params"] = [["owner": owner]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            completionHandler(offerData.description, nil)
        }
    }
    
    static func getEstimateGasPrice(completionHandler: @escaping (_ gasPrice: Double?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getEstimateGasPrice"
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let result = json["result"].stringValue
            if let amount = Asset.getAmount(of: "ETH", fromWeiAmount: result) {
                completionHandler(amount, nil)
            }
        }
    }

    // Ready
    static func getFrozenLRCFee(owner: String, completionHandler: @escaping (_ frozenLRCFee: Double?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getFrozenLRCFee"
        body["params"] = [["owner": owner, "delegateAddress": RelayAPIConfiguration.delegateAddress]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let result = json["result"].stringValue
            if let amount = Asset.getAmount(of: "LRC", fromWeiAmount: result) {
                completionHandler(amount, nil)
            }
        }
    }

    static func getPortfolio(owner: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPortfolio"
        body["params"] = [["owner": owner]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            completionHandler(offerData.description, nil)
        }
    }

    // Ready
    static func notifyTransactionSubmitted(txHash: String, rawTx: RawTransaction, from: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_notifyTransactionSubmitted"
        body["params"] = [["hash": txHash, "nonce": rawTx.nonce.hex, "to": rawTx.to, "value": rawTx.value, "gasPrice": rawTx.gasPrice, "gas": rawTx.gasLimit, "input": rawTx.data, "from": from]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { _, _, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            // It should return txHash
            completionHandler(txHash, nil)
        }
    }
    
    static func submitOrder(owner: String, walletAddress: String, tokenS: String, tokenB: String, amountS: String, amountB: String, lrcFee: String, validSince: String, validUntil: String, marginSplitPercentage: UInt8, buyNoMoreThanAmountB: Bool, authAddr: String, authPrivateKey: String?, powNonce: Int, orderType: String, v: UInt, r: String, s: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        
        var body: JSON = JSON()
        let protocolValue = RelayAPIConfiguration.protocolAddress
        let delegateAddress = RelayAPIConfiguration.delegateAddress
        body["params"] = [["delegateAddress": delegateAddress, "protocol": protocolValue, "owner": owner, "walletAddress": walletAddress, "tokenS": tokenS, "tokenB": tokenB, "amountS": amountS, "amountB": amountB, "authPrivateKey": authPrivateKey, "authAddr": authAddr, "validSince": validSince, "validUntil": validUntil, "lrcFee": lrcFee, "buyNoMoreThanAmountB": buyNoMoreThanAmountB, "marginSplitPercentage": marginSplitPercentage, "powNonce": powNonce, "orderType": orderType, "v": v, "r": r, "s": s]]

        self.invoke(method: "loopring_submitOrder", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
    
    static func cancelOrder(owner: String, type: CancelType, orderHash: String?, cutoff: Int64?, tokenS: String?, tokenB: String?, signature: SignatureData, timestamp: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["params"] = [["orderHash": orderHash, "type": type.rawValue, "cutoff": cutoff, "tokenS": tokenS, "tokenB": tokenB, "sign": ["timestamp": timestamp, "v": Int(signature.v)!, "r": signature.r, "s": signature.s, "owner": owner]]]
        self.invoke(method: "loopring_flexCancelOrder", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
    
    static func submitRing(makerOrderHash: String, takerOrderHash: String, rawTx: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        let protocolValue = RelayAPIConfiguration.protocolAddress
        let delegateAddress = RelayAPIConfiguration.delegateAddress
        body["params"] = [["delegateAddress": delegateAddress, "protocol": protocolValue, "takerOrderHash": takerOrderHash, "makerOrderHash": makerOrderHash, "rawTx": rawTx]]
        self.invoke(method: "loopring_submitRingForP2P", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
    
    static func getSignMessage(message hash: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTempStore"
        body["params"] = [["key": hash]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let result = json["result"].stringValue
            completionHandler(result, nil)
        }
    }
    
    static func updateScanLogin(owner: String, uuid: String, signature: SignatureData, timestamp: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["params"] = [["owner": owner, "uuid": uuid, "sign": ["timestamp": timestamp, "v": Int(signature.v)!, "r": signature.r, "s": signature.s, "owner": owner]]]
        self.invoke(method: "loopring_notifyScanLogin", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
    
    static func notifyStatus(hash: String, status: SignStatus, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address else {
            return
        }
        var body: JSON = JSON()
        body["params"] = [["owner": owner, "body": ["hash": hash, "status": status.description]]]
        self.invoke(method: "loopring_notifyCirculr", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
    
    static func getNonce(owner: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["params"] = [["owner": owner]]
        self.invoke(method: "loopring_getNonce", withBody: &body) { (_ data: SimpleRespond?, _ error: Error?) in
            guard error == nil && data != nil else {
                completionHandler(nil, error!)
                return
            }
            completionHandler(data!.respond, nil)
        }
    }
}
