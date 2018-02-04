//
//  Request.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Request {
    
    static let url = URL(string: "https://relay1.loopring.io/rpc")!

    // TODO: Add a closure
    static func getOrder() {
        var body: JSON = JSON()
        body["method"] = "loopring_getOrders"
        body["params"] = [["ringHash": nil, "pageIndex": 0, "pageSize": 20]]
        body["contractVersion"] = "v1.0"
        body["id"] = "1a715e2557abc0bd"

        request(body: body)
    }
    
    static func request(body: JSON) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
           try request.httpBody = body.rawData()
        } catch (_) {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            let json = JSON(data)
            print("response = \(json)")
        }
        task.resume()
    }

}
