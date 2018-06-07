//
//  TokenDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

private let whiteList: [String] = ["BAT", "RDN", "VITE", "WETH", "RHOC", "BNT", "ZRX", "DAI", "REQ", "ARP", "OMG", "IOST", "SNT", "ETH", "EOS", "LRC", "KNC"]
private let blackList: [String] = [] // ["BAR", "FOO"]

class TokenDataManager {
    
    static let shared = TokenDataManager()
    private var tokens: [Token]
    
    // A token is added to tokenList when
    // 1. the amount is not zero in the device one time.
    // 2. users enable in AddTokenViewController.
    // Default value is ["ETH"]
    private var tokenList: [String]

    private init() {
        self.tokens = []
        self.tokenList = []
        self.loadTokens()
    }

    func loadTokens() {
        getTokenListFromLocalStorage()
        loadTokensFromJson()
        loadTokensFromServer()
    }

    func getTokenList() -> [String] {
        return tokenList
    }

    func getTokenListFromLocalStorage() {
        let defaults = UserDefaults.standard
        tokenList = defaults.array(forKey: UserDefaultsKeys.tokenList.rawValue) as? [String] ?? ["ETH"]
        tokenList = Array(NSOrderedSet(array: tokenList)) as! [String]
    }
    
    func updateTokenList(tokenSymbol: String, add: Bool) {
        let defaults = UserDefaults.standard
        if add {
            if !tokenList.contains(tokenSymbol) {
                tokenList.append(tokenSymbol)
                defaults.set(tokenList, forKey: UserDefaultsKeys.tokenList.rawValue)
            }
        } else {
            tokenList = tokenList.filter {$0 != tokenSymbol}
            defaults.set(tokenList, forKey: UserDefaultsKeys.tokenList.rawValue)
        }
        
    }

    // load tokens from json file to avoid http request
    func loadTokensFromJson() {
        if let path = Bundle.main.path(forResource: "tokens", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let token = Token(json: subJson)
                if whiteList.contains(token.symbol.uppercased()) {
                    tokens.append(token)
                }
            }
            tokens.sort(by: { (a, b) -> Bool in
                return a.symbol < b.symbol
            })
        }
    }
    
    func loadTokensFromServer() {
        LoopringAPIRequest.getSupportedTokens { (tokens, error) in
            guard let tokens = tokens, error == nil else {
                return
            }
            for token in tokens {
                // Check if the token exists in self.tokens.
                if !self.tokens.contains(where: { (element) -> Bool in
                    return element.symbol.lowercased() == token.symbol.lowercased()
                }) {
                    if !blackList.contains(token.symbol.uppercased()) {
                        self.tokens.append(token)
                    }
                }
            }
        }
    }

    // Get a list of tokens
    func getTokens() -> [Token] {
        return tokens
    }

    func getTokenBySymbol(_ symbol: String) -> Token? {
        var result: Token? = nil
        for case let token in tokens where token.symbol.lowercased() == symbol.lowercased() {
            result = token
            break
        }
        return result
    }
    
    func getTokenByAddress(_ address: String) -> Token? {
        var result: Token? = nil
        for case let token in tokens where token.protocol_value.lowercased() == address.lowercased() {
            result = token
            break
        }
        return result
    }
    
    func getAddress(by symbol: String) -> String? {
        if let token = getTokenBySymbol(symbol) {
            return token.protocol_value
        } else {
            return nil
        }
    }
    
    
}
