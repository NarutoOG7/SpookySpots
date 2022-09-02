//
//  Network.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/30/22.
//

import Foundation
import Network

class Network: ObservableObject {
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published private(set) var connected: Bool = false
    
//    func checkConnection() {
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                
                if path.status == .satisfied {
                    self.connected = true
                } else {
                    self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
    
}
