//
//  BluetoothManager.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import CoreBluetooth
import Combine

protocol BluetoothAgentProtocol {
    var discoveredDevice :PassthroughSubject<(CBPeripheral, Int), Never> { get }
    var didFinishScanning: PassthroughSubject<Bool, Never> { get }
    var errorSubject: PassthroughSubject<BluetoothError, Never> { get }
    
    func startScanning(timeout: TimeInterval?)
    func stopScanning()
}

class BluetoothAgent: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, BluetoothAgentProtocol {
    // MARK: - Dependenties
    private var centralManager: CBCentralManager!
    
    // MARK: - Private properties
    private var isScanning = false
    private var discoveredPeripheralsUUIDs = Set<UUID>()
    
    // MARK: - Protcol Properties
    var discoveredDevice = PassthroughSubject<(CBPeripheral, Int), Never>()
    var didFinishScanning = PassthroughSubject<Bool, Never>()
    var errorSubject = PassthroughSubject<BluetoothError, Never>()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Protcol Methods
    func startScanning(timeout: TimeInterval? = nil) {
        
        guard centralManager.state == .poweredOn else {
            let error: BluetoothError
            switch centralManager.state {
            case .poweredOff:
                error = .poweredOff
            case .unauthorized:
                error = .unauthorized
            case .unsupported:
                error = .unsupported
            default:
                error = .unknownState
            }
            errorSubject.send(error)
            return
        }
        
        discoveredPeripheralsUUIDs.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        if let timeout {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                self?.stopScanning()
            }
        }
    }
    
    func stopScanning() {
        guard isScanning else { return }
        centralManager.stopScan()
        isScanning = false
        didFinishScanning.send(true)
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .poweredOn:
                print("Bluetooth включен")
            case .poweredOff:
                errorSubject.send(.poweredOff)
            case .unauthorized:
                errorSubject.send(.unauthorized)
            case .unsupported:
                errorSubject.send(.unsupported)
            case .resetting, .unknown:
                errorSubject.send(.unknownState)
            @unknown default:
                errorSubject.send(.unknownState)
            }
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripheralsUUIDs.contains(peripheral.identifier) {
            discoveredPeripheralsUUIDs.insert(peripheral.identifier)
            discoveredDevice.send((peripheral, Int(truncating: RSSI)))
        }
    }
}
