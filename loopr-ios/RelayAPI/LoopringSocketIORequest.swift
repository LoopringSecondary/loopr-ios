//
//  LoopringWebSocketCaller.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/11.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

public class LoopringSocketIORequest {
    
    static let shared = LoopringSocketIORequest()
    
    var manager: SocketManager
    var socket: SocketIOClient

    private init() {
        manager = SocketManager(socketURL: URL(string: "http://13.112.62.24")!, config: [.log(true), .compress, .forceWebsockets(true), .forcePolling(false)])
        socket = manager.defaultSocket
    }
    
    func setup() {
        addHandlers()
        socket.connect()
    }
    
    func addHandlers() {
        socket.on("balance_res") { data, _ in
            let json = JSON(data)
            print(json)
            return
        }
    }
    
    public func getBalance(owner: String?) {
        var body: JSON = JSON()
        body["owner"] = JSON(owner!)
        print("\nemitting......\n")
        print("\n\(socket.status.description)\n") // always connecting, could not emit!!!
        socket.emit("balance_req", [body])
    }
}
