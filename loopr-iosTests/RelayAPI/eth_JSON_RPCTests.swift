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
    
    func testExample() {
        let expectation = XCTestExpectation()
        
        eth_JSON_RPC.eth_getBalance() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
