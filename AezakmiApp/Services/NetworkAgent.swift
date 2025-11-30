//
//  NetworkAgent.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

protocol NetworkAgentProtocol {
    var deviceDiscoveredSubject: PassthroughSubject<MMDevice, Never> { get}
    var didFinishScanning: PassthroughSubject<Bool, Never> { get }
    var errorSubject: PassthroughSubject<LanError, Never> { get }
    
    func startScanning(timeout: TimeInterval?)
    func stopScanning()
}

final class NetworkAgent: NSObject, MMLANScannerDelegate, NetworkAgentProtocol {
    
    // MARK: - Private Properties
    private var isScanning: Bool = false
    private var lanScanner : MMLANScanner!
    private var discoveredDevicesUUIDs = Set<String>()
    
    // MARK: - Protocol Properties
    var deviceDiscoveredSubject = PassthroughSubject<MMDevice, Never>()
    var didFinishScanning = PassthroughSubject<Bool, Never>()
    var errorSubject =  PassthroughSubject<LanError, Never>()
    
    override init() {
        super.init()
        self.lanScanner = MMLANScanner(delegate:self)
    }
    
    // MARK: - MMLANScannerDelegate
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        guard let ip = device.ipAddress else { return }
        if !discoveredDevicesUUIDs.contains(ip) {
            discoveredDevicesUUIDs.insert(ip)
            deviceDiscoveredSubject.send(device)
        }
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        self.isScanning = false
        self.didFinishScanning.send(true)
    }
    
    func lanScanDidFailedToScan() {
        self.errorSubject.send(.unknownState)
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
    }
    
    // MARK: - Protocol Methods
    func startScanning(timeout: TimeInterval? = nil) {
        guard !isScanning else { return }
        isScanning = true
        discoveredDevicesUUIDs.removeAll()
        self.lanScanner.start()
        
        if let timeout {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                self?.stopScanning()
            }
        }
    }
    
    func stopScanning() {
        guard isScanning else { return}
        self.lanScanner.stop()
    }
}
