//
//  eth_JSON_RPC.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 2/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
import SwiftyJSON

class eth_JSON_RPCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // its ok to pass nil or real value to method, e.g. owner, same as below
    func testCall() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_call(from: nil, to: "0x98C9D14a894d19a38744d41CD016D89Cf9699a51", gas: nil, gasPrice: nil, value: nil, data: nil) { data, response, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            print(data)
            
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}
