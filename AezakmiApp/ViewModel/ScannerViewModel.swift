//
//  ScanViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import Combine

final class ScannerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var bluetoothDevices: [BluetoothDeviceModel] = []
    @Published var lanDevices: [LanDeviceModel] = []
    @Published var isScanActive: Bool = false
    @Published private(set) var devicesCount: Int = 0
    @Published var bluetoothError: BluetoothError?
    @Published var lanError: LanError?
    
    // MARK: - Private Properties
    private let scanSessionRepository: ScanSessionRepositoryProtocol
    private let btRepository: BluetoothRepositoryProtocol
    private let lanRepository: LanRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var lanFinished = false
    private var btFinished = false
    
    // MARK: - INIT
    init(
        scanSessionRepository: ScanSessionRepositoryProtocol,
        btRepository: BluetoothRepositoryProtocol,
        lanRepository: LanRepositoryProtocol
    ) {
        self.scanSessionRepository = scanSessionRepository
        self.btRepository = btRepository
        self.lanRepository = lanRepository
        bind()
    }
    
    
    private func bind() {
        //MARK: - Devices Streasm
        btRepository.deviceStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.bluetoothDevices.append(device)
                self?.devicesCount += 1
            }
            .store(in: &cancellables)
        
        lanRepository.deviceStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.lanDevices.append(device)
                self?.devicesCount += 1
            }
            .store(in: &cancellables)
        
        //MARK: - DidFinishScanningStream
        Publishers.Zip(btRepository.didFinishScanning,
                       lanRepository.didFinishScanning)
        .print()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self]_,_ in
            guard let self else { return }
            self.isScanActive = false
            self.saveCurrentSession()
        })
        .store(in: &cancellables)
        
        // MARK: - Error Streams
        btRepository.errorStream
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] error in
                        self?.bluetoothError = error
                        self?.isScanActive = false
                        print(error.localizedDescription)
                    }
                    .store(in: &cancellables)
        
        lanRepository.errorStream
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] error in
                        self?.lanError = error
                        self?.isScanActive = false
                        print(error.localizedDescription)
                    }
                    .store(in: &cancellables)
    }
    
    func startScanning(timeout: TimeInterval) {
        bluetoothDevices = []
        lanDevices = []
        devicesCount = 0
        isScanActive = true
        
        btRepository.startScanning(timeout: timeout)
        lanRepository.startScanning(timeout: timeout)
    }
    
    func stopScanning() {
        btRepository.stopScanning()
        lanRepository.stopScanning()
    }
    
    private func saveCurrentSession() {
        do {
            try scanSessionRepository.saveSession(
                lanDevices: lanDevices,
                btDevices: bluetoothDevices
            )
        } catch {
            print("Не удалось сохранить сессию: \(error)")
        }
    }
}
