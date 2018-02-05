//
//  loopr_iosTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
import SwiftyJSON

class JSON_RPCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBalance() {
        JSON_RPC.getBalance() { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
    }
    
    func testGetOrder() {
        JSON_RPC.getOrders() { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
    }
    
    func testGetDepth() {
        JSON_RPC.getDepth() { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
    }
}
