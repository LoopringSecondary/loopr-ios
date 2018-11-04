//
//  Request.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import SVProgressHUD

public typealias CompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

class Request {
    
    static let banner = NotificationBanner.generate(title: "No network", style: .warning)
    
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
                DispatchQueue.main.async {
                    if !banner.isDisplaying {
                        banner.duration = 60.0
                        banner.show()
                    }
                    SVProgressHUD.dismiss()
                }
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
    
    static func get(_ url: String, parameters: [String: String], completionHandler: @escaping CompletionHandler) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    return
            }
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completionHandler(data, response, error)
        }
        task.resume()
    }

}
