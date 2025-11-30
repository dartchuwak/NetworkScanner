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
    private let deviceStreamSubject = PassthroughSubject<BluetoothDeviceModel, Never>()
    private var cancellables = Set<AnyCancellable>()
    
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
            state: device.state.rawValue.description
        )
    }
    
    // MARK: Protocol Methods
    func startScanning(timeout: TimeInterval? = nil) {
        agent.startScanning(timeout: timeout)
    }
    
    func stopScanning() {
        agent.stopScanning()
    }
}
