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
    @Published private(set)var bluetoothDevices: [BluetoothDeviceModel] = []
    @Published private(set)var lanDevices: [LanDeviceModel] = []
    @Published private(set)var isScanActive: Bool = false
    @Published private(set) var devicesCount: Int = 0
    @Published private(set)var scanProgress: CGFloat = 0
    @Published var scanError: ScanError?
    @Published var showScanerAnimationView: Bool = false
    
    // MARK: - Private Properties
    private let scanSessionRepository: ScanSessionRepositoryProtocol
    private let btRepository: BluetoothRepositoryProtocol
    private let lanRepository: LanRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var progressTimer: AnyCancellable?
    private var scanStartDate: Date?
    private var scanDuration: TimeInterval = 0
    
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
                self?.stopScanning()
                self?.scanError = .bluetooth(error)
                self?.isScanActive = false
                self?.showScanerAnimationView = false
            }
            .store(in: &cancellables)
        
        lanRepository.errorStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.stopScanning()
                self?.scanError = .lan(error)
                self?.isScanActive = false
                self?.showScanerAnimationView = false
               
            }
            .store(in: &cancellables)
    }
    
    func startScanning(timeout: TimeInterval) {
        bluetoothDevices = []
        lanDevices = []
        devicesCount = 0
        isScanActive = true
        showScanerAnimationView = true
        
        scanStartDate = Date()
        scanDuration = timeout
        
        progressTimer?.cancel()
        progressTimer = Timer
            .publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self,
                      let start = self.scanStartDate else { return }
                
                let elapsed = now.timeIntervalSince(start)
                let progress = min(elapsed / self.scanDuration, 1)
                self.scanProgress = CGFloat(progress)
                
                if progress >= 1 {
                    self.progressTimer?.cancel()
                }
            }
        
        btRepository.startScanning(timeout: timeout)
        lanRepository.startScanning(timeout: timeout)
    }
    
    func stopScanning() {
        btRepository.stopScanning()
        lanRepository.stopScanning()
        progressTimer?.cancel()
        progressTimer = nil
        scanProgress = 1
    }
    
    private func saveCurrentSession() {
        
        let lan = lanDevices
        let bt  = bluetoothDevices
        
        Task {
            do {
                try await scanSessionRepository.saveSessionAsync(lanDevices:lan, btDevices: bt)
            } catch {
                print("Не удалось сохранить сессию: \(error)")
            }
        }
    }
}
