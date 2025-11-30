//
//  LanRepository.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import Foundation
import Combine

protocol LanRepositoryProtocol {
    var deviceStream: AnyPublisher<LanDeviceModel, Never> { get }
    var didFinishScanning: AnyPublisher<Bool, Never> { get }
    var errorStream: AnyPublisher<LanError, Never> { get }
    
    func stopScanning()
    func startScanning(timeout: TimeInterval?)
}

final class LanRepository: LanRepositoryProtocol {
    
    private let agent: NetworkAgentProtocol
    private let deviceStreamSubject = PassthroughSubject<LanDeviceModel, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var deviceStream: AnyPublisher<LanDeviceModel, Never> {
        agent.deviceDiscoveredSubject
            .map { [weak self] raw -> LanDeviceModel in
                guard let self else {
                    return LanDeviceModel(name: "Неизвестное устройство",
                                          ipAdress: "IP не распознан",
                                          macAddress: "MAC не распознан")
                }
                return self.map(raw)
            }
            .eraseToAnyPublisher()
        
    }
    
    var errorStream: AnyPublisher<LanError, Never> {
        agent.errorSubject
            .eraseToAnyPublisher()
    }
    var didFinishScanning: AnyPublisher<Bool, Never> {
        agent.didFinishScanning
            .eraseToAnyPublisher()
    }
    
    init(agent: NetworkAgentProtocol) {
        self.agent = agent
    }
    
    private func map(_ raw: MMDevice) -> LanDeviceModel {
        LanDeviceModel(name: raw.hostname ?? "Неизвестное устройство",
                       ipAdress: raw.ipAddress ?? "IP не распознан",
                       macAddress: raw.macAddress ?? "MAC не распознан")
    }
    
    func startScanning(timeout: TimeInterval? = nil) {
        agent.startScanning(timeout: timeout)
    }
    
    func stopScanning() {
        agent.stopScanning()
    }
    
}



