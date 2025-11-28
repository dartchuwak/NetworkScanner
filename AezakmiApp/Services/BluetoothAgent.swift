//
//  BluetoothManager.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import CoreBluetooth
import Combine

protocol BluetoothAgentProtocol {
    var deviceDiscoveredSubject :PassthroughSubject<BluetoothDeviceModel, Never> { get }
    var scanSessionSubject: PassthroughSubject<[BluetoothDeviceModel], Never> { get }
    
    func startScanning()
    func stopScanning()
}

class BluetoothAgent: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, BluetoothAgentProtocol {
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripheralsUUIDs = Set<UUID>()
    
    var deviceDiscoveredSubject = PassthroughSubject<BluetoothDeviceModel, Never>()
    var scanSessionSubject = PassthroughSubject<[BluetoothDeviceModel], Never>()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth не включен.")
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
        print("Stopped scanning")
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth включен")
        case .poweredOff:
            print("Bluetooth выключен")
            //     showBluetoothAlert()
        case .resetting:
            print("Bluetooth сбрасывается")
        case .unauthorized:
            print("Bluetooth не авторизован")
        case .unknown:
            print("Неизвестное состояние Bluetooth")
        case .unsupported:
            print("Bluetooth не поддерживается")
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Неизвестное устройство"
        let uuid = peripheral.identifier
        let status = peripheral.state
        let rssiValue = RSSI.intValue
        
        if !discoveredPeripheralsUUIDs.contains(uuid) {
            let device = BluetoothDeviceModel(name: name, rssi: rssiValue, uuid: uuid, peripheralState: status)
            discoveredPeripheralsUUIDs.insert(uuid)
            deviceDiscoveredSubject.send(device)
        }
    }
}
