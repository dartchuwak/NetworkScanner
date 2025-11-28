//
//  NetworkAgent.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

protocol NetworkAgentProtocol {
    var deviceDiscoveredSubject: PassthroughSubject<LanDeviceModel, Never> { get}
    var didFinishScanning: PassthroughSubject<Void, Never> { get }
    
    func startScanning()
    func stopScanning()
}

final class NetworkAgent: NSObject, MMLANScannerDelegate, NetworkAgentProtocol {
    
    private var lanScanner : MMLANScanner!
    private var discoveredDevicesUUIDs = Set<String>()
    
    var deviceDiscoveredSubject = PassthroughSubject<LanDeviceModel, Never>()
    var didFinishScanning = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        self.lanScanner = MMLANScanner(delegate:self)
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        guard let ip = device.ipAddress else { return }
        if !discoveredDevicesUUIDs.contains(ip) {
            let lanDevice = LanDeviceModel(name: device.hostname ?? "Неизвестное устройство",
                                           ipAdress: device.ipAddress ?? "IP-адресс неизвестен",
                                           macAddress: device.macAddress ?? "MAC-адресс неизвестен")
            discoveredDevicesUUIDs.insert(ip)
            deviceDiscoveredSubject.send(lanDevice)
        }
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        DispatchQueue.main.async {
            self.didFinishScanning.send()
        }
        
    }
    
    func lanScanDidFailedToScan() {
        
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        
    }
    
    func startScanning() {
        discoveredDevicesUUIDs.removeAll()
        self.lanScanner.start()
    }
    
    func stopScanning() {
        self.lanScanner.stop()
    }
}
