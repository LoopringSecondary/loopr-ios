//
//  TokenDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class TokenDataManager {
    
    static let shared = TokenDataManager()

    private var tokens: [Token]

    private init() {
        self.tokens = []
        self.loadTokens()
    }

    func loadTokens() {
        loadTokensFromJson()
        loadTokensFromServer()
    }
    
    // load tokens from json file to avoid http request
    func loadTokensFromJson() {
        if let path = Bundle.main.path(forResource: "tokens", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
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
                    self.tokens.append(token)
                }
            }
        }
    }

    // Get a list of tokens
    func getTokens() -> [Token] {
        return tokens
    }
    
    func getUnlistedTokensInCurrentAppWallet() -> [Token] {
        guard let appWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet() else {
            return tokens
        }

        var unlistedTokens: [Token] = []
        for token in tokens {
            if !appWallet.getAssetSequence().contains(token.symbol) {
                unlistedTokens.append(token)
            }
        }
        return unlistedTokens
    }

    func getTokenBySymbol(_ symbol: String) -> Token? {
        var result: Token? = nil
        for case let token in tokens where token.symbol.lowercased() == symbol.lowercased() {
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
