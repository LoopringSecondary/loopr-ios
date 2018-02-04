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

    static func sendExampleRequest() {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //{"method":"loopring_getOrders","params":[{"ringHash":null,"pageIndex":0,"pageSize":10,"contractVersion":"v1.0"}],"id":"1a715e2557abc0bd"}
        let postString = "{\"method\":\"loopring_getOrders\",\"params\":[{\"ringHash\":null,\"pageIndex\":0,\"pageSize\":10,\"contractVersion\":\"v1.0\"}],\"id\":\"1a715e2557abc0bd\"}"
        
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            let json = JSON(data)
            print("response = \(json)")
        }
        task.resume()
    }

}
