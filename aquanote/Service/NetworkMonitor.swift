//
//  NetworkMonitor.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/27.
//

import Network
import FirebaseFirestore
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    
    var isConnected: Bool = false

    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: .global())
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.isConnected = true
                FIRStoreService.shared.processPendingWrites()
                NotificationCenter.default
                    .post(name: NSNotification.Name(rawValue: "NetworkConnectionEnable"), object: nil)
            } else {
                self?.isConnected = false
                NotificationCenter.default
                    .post(name: NSNotification.Name(rawValue: "NetworkConnectionDisable"), object: nil)
            }
       }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
