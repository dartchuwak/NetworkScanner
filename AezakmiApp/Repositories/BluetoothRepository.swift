//
//  Repositories.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import Foundation
import Combine
import CoreBluetooth

protocol BluetoothRepositoryProtocol {
    var deviceStream: AnyPublisher<BluetoothDeviceModel, Never> { get }
    var errorStream: AnyPublisher<BluetoothError, Never> { get }
    var didFinishScanning: AnyPublisher<Bool, Never> { get }
    
    func stopScanning()
    func startScanning(timeout: TimeInterval?)
}

final class BluetoothRepository: BluetoothRepositoryProtocol {
    
    // MARK: Private properties
    private let agent: BluetoothAgentProtocol
    
    // MARK: Protocol properties
    var deviceStream: AnyPublisher<BluetoothDeviceModel, Never> {
        agent.discoveredDevice
            .map { [weak self] raw -> BluetoothDeviceModel in
                guard let self else {
                    return BluetoothDeviceModel(
                        name: "Неизвестное устройство",
                        rssi: 0,
                        uuid: "Неизвестно",
                        state: "Неизвестно"
                    )
                }
                return self.map(device: raw.0, RSSI: raw.1)
            }
            .eraseToAnyPublisher()
        
    }
    
    var errorStream: AnyPublisher<BluetoothError, Never> {
        agent.errorSubject
            .eraseToAnyPublisher()
    }
    
    var didFinishScanning: AnyPublisher<Bool, Never> {
        agent.didFinishScanning
            .eraseToAnyPublisher()
    }
    
    // MARK: INIT
    init(agent: BluetoothAgentProtocol) {
        self.agent = agent
    }
    
    // MARK: Private Methods
    private func map(device: CBPeripheral, RSSI: Int) -> BluetoothDeviceModel {
        BluetoothDeviceModel(
            name: device.name ?? "Неизвестное устройство",
            rssi: RSSI,
            uuid: device.identifier.uuidString,
            state: mapState(device.state)
        )
    }
    
    private func mapState(_ state: CBPeripheralState) -> String {
        switch state {
        case .disconnected:
            return "Отключено"
        case .connecting:
            return "Подключается"
        case .connected:
            return "Подключено"
        case .disconnecting:
            return "Отключается"
        @unknown default:
            return "Неизвестное состояние"
        }
    }
    
    // MARK: Protocol Methods
    func startScanning(timeout: TimeInterval? = nil) {
        agent.startScanning(timeout: timeout)
    }
    
    func stopScanning() {
        agent.stopScanning()
    }
}
