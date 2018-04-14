//
//  RelayAPIConfiguration.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class RelayAPIConfiguration {

    // Test environment
    // static let baseUrl = "http://13.112.62.24"

    static let baseURL = "https://relay1.loopring.io"
    static let rpcURL = URL(string: baseURL + "/rpc/v2")!
    static let ethURL = URL(string: baseURL + "/eth")!
    static let socketURL = URL(string: baseURL)!

    static let contractVersion = "v1.2"
}
