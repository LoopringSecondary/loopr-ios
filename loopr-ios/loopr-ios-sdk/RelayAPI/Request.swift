//
//  Request.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

class Request {
    
    static func send(body: JSON, url: URL, completionHandler: @escaping CompletionHandler) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            try request.httpBody = body.rawData()
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            completionHandler(data, response, error)
        }
        task.resume()
    }

}
