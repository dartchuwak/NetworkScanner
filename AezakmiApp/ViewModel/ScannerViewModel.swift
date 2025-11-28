//
//  ScanViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import Combine

final class ScannerViewModel: ObservableObject {
    
    @Published var bluetoothDevices: [BluetoothDeviceModel] = []
    @Published var lanDevices: [LanDeviceModel] = []
    @Published var isScanActive: Bool = false
    
   
    
    private var cancellables: Set<AnyCancellable> = []
    private var timer: AnyCancellable?
    
    // MARK: Зависимости
    
    private let coreDataStack: CoreDataStack
    private var bluetoothAgent: BluetoothAgentProtocol?
    private var networkAgent: NetworkAgentProtocol?
    
    private var lanFinished = false
    private var btFinished = false
    
    private var foundBTDevices: [BluetoothDeviceModel] = []
    private var foundLANDevices: [LanDeviceModel] = []
    
    init(btAgent: BluetoothAgentProtocol, lanAgent: NetworkAgentProtocol, coreDataStack: CoreDataStack) {
        self.bluetoothAgent = btAgent
        self.networkAgent = lanAgent
        self.coreDataStack = coreDataStack
        bluetoothAgent?.deviceDiscoveredSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] device in
                self?.foundBTDevices.append(device)
            })
            .store(in: &cancellables)
        
        networkAgent?.deviceDiscoveredSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] device in
                self?.foundLANDevices.append(device)
            })
            .store(in: &cancellables)
    }
    
    private func scanFinishedIfNeeded() {
        guard lanFinished && btFinished else { return }
        
        do {
            try coreDataStack.saveScanSession(
                lanDevices: lanDevices,
                bluetoothDevices: bluetoothDevices
            )
        } catch {
            print("Не удалось сохранить сессию: \(error)")
        }
    }
    
    
    func startScanning() {
        clearFoundDevices()
        lanFinished = false
        btFinished = false
        isScanActive = true
        bluetoothAgent?.startScanning()
        networkAgent?.startScanning()
        
        timer = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.stopScanning()
            }
    }
    
    private func clearFoundDevices() {
        lanDevices.removeAll()
        bluetoothDevices.removeAll()
        foundBTDevices.removeAll()
        foundLANDevices.removeAll()
    }
    
    
    func stopScanning() {
        bluetoothAgent?.stopScanning()
        networkAgent?.stopScanning()
        self.bluetoothDevices = foundBTDevices
        self.lanDevices = foundLANDevices
        lanFinished = true
        btFinished = true
        isScanActive = false
        timer?.cancel()
        timer = nil
        scanFinishedIfNeeded()
    }
}
