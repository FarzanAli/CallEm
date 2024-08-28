//
//  SocketManager.swift
//  CallEm
//
//  Created by Farzan Ali Faisal on 2024-08-25.
//

import Foundation
import SocketIO
import KeychainAccess

class Socket: ObservableObject {
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    @Published var outgoingCallerSid: String? {
        didSet {
            // Store the SID in the keychain whenever it's set
            if let sid = outgoingCallerSid {
                keychain["outgoingCallerSid"] = sid
            }
        }
    }
    
    init() {
        // Replace "http://localhost:4000" with your server's URL
        manager = SocketManager(socketURL: URL(string: "http://localhost:4000")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        outgoingCallerSid = keychain["outgoingCallerSid"]
        setupHandlers()
    }
    
    private let keychain = Keychain(service: "com.CallEm")
    
    func getOutgoingCallerSid() -> String? {
        return keychain["outgoingCallerSid"]
    }
    
    func storeOutgoingCallerSid(sid: String) {
        keychain["outgoingCallerSid"] = sid
    }
    
    func deleteOutgoingCallerSid() {
        do {
            try keychain.remove("outgoingCallerSid")
            outgoingCallerSid = nil
        } catch let error {
            print("Error deleting outgoingCallerSid from Keychain: \(error.localizedDescription)")
        }
    }
    
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    private func setupHandlers() {
        // Handle connection events
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
        
        socket.on(clientEvent: .error) {data, ack in
            print("socket error: \(data)")
        }
        
        socket.on("message") { data, ack in
            print("here")
            print(data)
            if let messageData = data[0] as? [String: Any],
               let ver = messageData["verification"] as? String,
               let sid = messageData["outgoingCallerSid"] as? String {
                print("Received message: \(ver)")
                if ver == "success" {
                    DispatchQueue.main.async {
                        self.storeOutgoingCallerSid(sid: sid)
                        self.outgoingCallerSid = sid
                    }
                }
                
            } else {
                print("Invalid message format")
            }
        }
    }
    
    func sendEvent() {
        // Sending a custom event to the server
        socket.emit("yourCustomEvent", ["key": "value"])
    }
}
