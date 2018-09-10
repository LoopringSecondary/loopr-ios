//
//  WalletType.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

class WalletType: Equatable {
    
    final let name: String
    final let derivationPath: String
    
    init(name: String, derivationPath: String) {
        self.name = name
        self.derivationPath = derivationPath
    }
    
    static func == (lhs: WalletType, rhs: WalletType) -> Bool {
        return lhs.name == rhs.name && lhs.derivationPath == rhs.derivationPath
    }
    
    // Default is Tokenest Wallet
    class func getDefault() -> WalletType {
        return WalletType(name: "Tokenest Wallet", derivationPath: "m/44'/60'/0'/0")
    }
    
    class func getLoopringWallet() -> WalletType {
        return WalletType(name: "Loopring Wallet", derivationPath: "m/44'/60'/0'/0")
    }
    
    class func getList() -> [WalletType] {
        return [
            WalletType.getDefault(),
            getLoopringWallet(),
            WalletType(name: "imtoken", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "Metamask", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "TREZOR (ETH)", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "Digital Bitbox", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "Exodus", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "Jaxx", derivationPath: "m/44'/60'/0'/0"),
            WalletType(name: "Ledger (ETH)", derivationPath: "m/44'/60'/0'"),
            WalletType(name: "TREZOR (ETC)", derivationPath: "m/44'/61'/0'/0"),
            WalletType(name: "Ledger (ETC)", derivationPath: "m/44'/60'/160720'/0'"),
            WalletType(name: "SingularDTV", derivationPath: "m/0'/0'/0'"),
            WalletType(name: "Network: Testnets", derivationPath: "m/44'/1'/0'/0"),
            WalletType(name: "Network: Expanse", derivationPath: "m/44'/40'/0'/0"),
            WalletType(name: "Network: Ubiq", derivationPath: "m/44'/108'/0'/0"),
            WalletType(name: "Network: Ellaism", derivationPath: "m/44'/163'/0'/0")
        ]
    }
}
