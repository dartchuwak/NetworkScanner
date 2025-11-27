//
//  ScanViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import Combine
import SwiftUI
import CoreBluetooth
import CoreData

final class ScannerViewModel: ObservableObject {
    
    @Published var devices: [BluetoothDeviceModel] = []
    @Published var isScanActive: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var timer: AnyCancellable?
    
    private var bluetoothManager: BluetoothAgent
    private var coreData = CoreDataStack.shared
    private var currentScanSession: ScanSession?
    
    private var foundDevices: [BluetoothDeviceModel] = []
    
    init() {
        bluetoothManager = BluetoothAgent()
        bluetoothManager.deviceDiscoveredSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] device in
                self?.foundDevices.append(device)
            })
            .store(in: &cancellables)
    }
    
    private func saveDeviceToCoreData(_ device: BluetoothDeviceModel) {
        CoreDataStack.shared.saveDevice(device: device)
    }
    
    func startScanning() {
        currentScanSession = ScanSession(context: CoreDataStack.shared.context)
        currentScanSession?.timestamp = Date()
        
        bluetoothManager.startScanning()
        isScanActive.toggle()
        
        timer = Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.stopScanning()
            }
    }
    
    func stopScanning() {
        bluetoothManager.stopScanning()
        if let _ = self.currentScanSession {
            CoreDataStack.shared.saveContext()
        }
        
        self.devices = foundDevices
        isScanActive.toggle()
        
        // Останавливаем таймер
        timer?.cancel()
        timer = nil
    }
}
