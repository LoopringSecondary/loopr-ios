//
//  LoopringWebSocketCaller.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/11.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import Starscream

public class LoopringWebSocketCaller: WebSocketDelegate {
    
    var socket: WebSocket!
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func connectSever() {
        
        var request = URLRequest(url: URL(string: "http://localhost:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func sendBrandStr(brandID: String) {
        socket.write(string: brandID)
    }
    
    func disconnect() {
        socket.disconnect()
    }
}
