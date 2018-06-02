//
//  PendingTransactionsDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class PendingTransactionsDataManager {
    
    static let shared = PendingTransactionsDataManager()
    private var transactions: [Transaction]

    private init() {
        transactions = []
    }
    
    
}
